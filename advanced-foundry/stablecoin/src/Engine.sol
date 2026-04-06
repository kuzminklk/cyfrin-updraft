


/* 
Layout of Smart-Contract: (in theory and in practice here)
1. Version
2. Imports
3. Interfaces, Libraries, Contracts
4. Errors
5. Types
6. State Variables
7. Events
8. Modifiers
9. Funcitons
*/

/* 
Layout of functions: (in theory)
1. Constructor
2. Recive Function
3. Fallback function
4. External
5. Public
6. Internal
7. Private
8. View, Pure
*/

/* 
Layout of functions sections: (in practice here)
1. Deposit
2. Mint Stablecoins
3. Collateral (Calculate, Redeem)
4. Burn Stablecoins
5. Health Factor
6. Liquidation
*/



// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import { ReentrancyGuardTransient } from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import { Stablecoin } from "./Stablecoin.sol";


/**
 * @title Stablecoin Engine
 * @author kuzminklk (Daniil Kuzmin)
 * @notice Meant to be the core of the stablecoin system, governing minting, burning, collateral managment and liquidation mechanics
 *
 * — Stablecoin System Description —
 * Relative Stability: Anchored (Pegged) to USD
 * Stability Mechanism (Minting): Algorithmic
 * Collateral: Exogenous (wETH, wBTC)
 * System always should be overcollateralized
 * (Similar to DAI, if DAI had no gevernance, no fees, and only backed by wETH, wBTC colateral)
 */
contract Engine is ReentrancyGuardTransient {

	// — Errors —

	error Engine__AmountMustBeGreaterThanZero();
	error Engine__TokensMustMatchPriceFeeds();
	error Engine__TokenNotAllowed();
	error Engine__TransferFailed();
	error Engine__BreaksHealthFactor(uint256 healthFactor);
	error Engine_MintFailed();

	// — State Variables —

	uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10; // Add 1e10 to 1e8 Price Feed precision to get 1e18 as common in Ethereum
	uint256 private constant PRECISION = 1e18;
	uint256 private constant LIQUIDATION_THRESHOLD = 10; // 10% liqudation buffer
	uint256 private constant MINIMAL_HEALTH_FACTOR = 1;

	Stablecoin immutable private i_stablecoin;

	mapping(address token => address priceFeed) private s_tokenToPriceFeed; /// Allowed for collateral tokens
	mapping(address user => mapping(address token => uint256 amount)) private s_userToDeposit;
	mapping(address user => uint256 mintedStablecoinsAmount) private s_userToMintedStablecoins;

	address[] private s_collateralTokens;

	// — Events —

	event CollateralDeposited(address indexed user, address indexed token, uint256 amount);
	event CollateralRedeemed(address indexed user, address indexed token, uint256 amount);

	// — Modifiers —

	modifier amountMoreThanZero(uint256 amount) {
		if (amount <= 0) {
			revert Engine__AmountMustBeGreaterThanZero();
		}
		_;
	}

	modifier allowedToken(address token) {
		if (s_tokenToPriceFeed[token] == address(0)) {
			revert Engine__TokenNotAllowed();
		}
		_;
	}


	// ——— Functions ———

	/**
	 * @param tokens Addresses of acceptable ERC20 tokens for collateral
	 * @param priceFeeds Price Feeds for these tokens
	 * @param stablecoin ERC20 Stablecoin for this Engine to mint and burn
	 * @dev Tokens and Price Feeds arrays must be in the same order, so we can map token to it's price feed by index
	 */
	constructor(address[] memory tokens, address[] memory priceFeeds, Stablecoin stablecoin) {
		if (tokens.length != priceFeeds.length) {
			revert Engine__TokensMustMatchPriceFeeds();
		}

		for (uint256 i; i < tokens.length; i++) {
			s_tokenToPriceFeed[tokens[i]] = priceFeeds[i];
			s_collateralTokens.push(tokens[i]);
		}

		i_stablecoin = stablecoin;
	}

	// — Deposit —

	/**
	 * @notice Deposit collateral to the system
	 * @param token The address of the token to deposit as collateral
	 * @param amount The amount of tokens as collateral
	 * @dev Follows CEI pattern, have reentrancy guard
	 */
	function depositCollateral(address token, uint256 amount) public amountMoreThanZero(amount) allowedToken(token) nonReentrant() {
		// Effects
		s_userToDeposit[msg.sender][token] += amount;
		emit CollateralDeposited(msg.sender, token, amount);
		// Interaction
		bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
		if (!success) {
			revert Engine__TransferFailed();
		}
	}

	function depositCollateralAndMintStablecoins(address collateralToken, uint256 collateralAmount, uint256 stablecoinsAmount ) public {
		depositCollateral(collateralToken, collateralAmount);
		mintStablecoins(stablecoinsAmount);
	}

	// — Mint Stablecoins —
	
	/**
	 * @param amount The amount of tokens to mint
	 * @dev User must have two times more collateral for minting value (*2 overcollateralization)
	 */
	function mintStablecoins(uint256 amount) public amountMoreThanZero(amount) nonReentrant() {
		s_userToMintedStablecoins[msg.sender] += amount;
		_checkHealthFactor(msg.sender);
		bool success = i_stablecoin.mint(msg.sender, amount);
		if (!success) {
			revert Engine_MintFailed();
		}
	}

	// — Collateral (Calculate, Redeem) —

	/**
	 * @notice Get total value of token amount in USD
	 * @dev Uses Chainlink Price Feeds
	 * @return total The total value of collateral in USD with 1e18 precision
	 */
	function getValueInUSD(address token, uint256 amount) public view returns (uint256) {
		AggregatorV3Interface priceFeed = AggregatorV3Interface(s_tokenToPriceFeed[token]);
		( , int256 price, , , ) = priceFeed.latestRoundData(); // Returns price with 1e8 precision
		return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
	}

	/**
	 * @notice Get the total value of collateral for a user
	 * @return total The total value of collateral in USD with 1e18 precision
	 */
	function getCollateralValue(address user) public view returns (uint256 total) {
		for(uint256 i = 0; i < s_collateralTokens.length; i++) {
			address token = s_collateralTokens[i];
			uint256 amount = s_userToDeposit[user][token];
			total += getValueInUSD(token, amount);
		}
		return total;
	}

	function redeemCollateral(address token, uint256 amount) public amountMoreThanZero(amount) nonReentrant() {
		s_userToDeposit[msg.sender][token] -= amount;
		emit CollateralRedeemed(msg.sender, token, amount);

		bool success = IERC20(token).transfer(msg.sender, amount);	
		if (!success) {
			revert Engine__TransferFailed();
		}
		_checkHealthFactor(msg.sender);
	}

	// — Burn Stablecoins —

	function burnStablecoins(uint256 amount) public amountMoreThanZero(amount) {
		s_userToMintedStablecoins[msg.sender] -= amount;
		bool success = i_stablecoin.transferFrom(msg.sender, address(this), amount);
		if (!success) {
			revert Engine__TransferFailed();
		}
		i_stablecoin.burn(amount);
	}

	function burnStablecoinsAndRedeemCollateral(address collateralToken, uint256 collateralAmount, uint256 stablecoinsAmount ) public {
		burnStablecoins(stablecoinsAmount);
		redeemCollateral(collateralToken, collateralAmount);
	}

	// — Health Factor —

	function _getUserState(address user) internal view returns(uint256 totalStablecoinsMinted, uint256 collateralValue /* In USD */) {
		totalStablecoinsMinted = s_userToMintedStablecoins[user];
		collateralValue = getCollateralValue(user);
	}

	/**
	 * @notice Health Factor shows how close user to liquidation. If it's under 1, user can get liquidated
	 * See example of mechanics in liquidation() documentation
	 */
	function getHealthFactor(address user) public view returns (uint256) {
		(uint256 totalStablecoinsMinted, uint256 collateralValue) = _getUserState(user);
		uint256 liquidationBuffer = (totalStablecoinsMinted * LIQUIDATION_THRESHOLD) / 100;
		return (collateralValue / (totalStablecoinsMinted + liquidationBuffer));
	}

	/**
	 * @notice Reverts if Health Factor breaks MINIMAL_HEALTH_FACTOR (usually 1)
	 */
	function _checkHealthFactor(address user) internal view {
		uint256 healthFactor = getHealthFactor(user);
		if (healthFactor < MINIMAL_HEALTH_FACTOR) {
			revert Engine__BreaksHealthFactor(healthFactor);
		}
	}

	// — Liquidation —

	/**
	 * Liquidation mechanics:
	 * 1. Alice put 100$ of wETH as collateral and take 50$ of Stablecoin (*2 overcollateralization)
	 * 2. ETH price goes down to 55$ and happens Alice liqudation (10% liqudation buffer)
	 * 3. Someone buys Alice wETH collateral (worth 55$) for 50$ of Stablecoin and grab extra 5$ as reward for liquidation
	 */
	function liqudate() external {

	}



}