


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
4. public
5. public
6. View, Pure
*/

/* 
Layout of test sections:
1. Interest Rate
2. Balance
3. Mint
4. Burn
5. Transfer
6. Roles
*/



// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { console, Test } from "forge-std/Test.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IAccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { CCIPLocalSimulatorFork, Register } from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";
import { IERC20 } from "@chainlink-ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import { RegistryModuleOwnerCustom } from "@chainlink-ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/RegistryModuleOwnerCustom.sol";
import { TokenAdminRegistry } from "@chainlink-ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/TokenAdminRegistry.sol";
import { RateLimiter } from "@chainlink-ccip/contracts/src/v0.8/ccip/libraries/RateLimiter.sol";
import { Client } from "@chainlink-ccip/contracts/src/v0.8/ccip/libraries/Client.sol";
import { IRouterClient } from "@chainlink-ccip/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import { TokenPool } from "@chainlink-ccip/contracts/src/v0.8/ccip/pools/TokenPool.sol";

import { Token } from "../src/Token.sol";
import { Vault } from "../src/Vault.sol";
import { IToken } from "../src/interfaces/IToken.sol";
import { CustomTokenPool } from "../src/CustomTokenPool.sol";


contract TestEngine is Test {

	// Users and balances
	address public OWNER = makeAddr("OWNER");
	uint256 public OWNER_INITIAL_BALANCE = 100 ether;
	address public USER_1 = makeAddr("USER_1");
	address public USER_2 = makeAddr("USER_2");
	uint256 public USER_1_INITIAL_BALANCE = 10 ether;
	uint256 public USER_2_INITIAL_BALANCE = 10 ether;
	uint256 public VAULT_INITIAL_BALANCE = 10 ether;

	// Percision
	uint256 public constant PRECISION = 1e18;

	// Interest rates
	uint256 public INITIAL_INTEREST_RATE = (5 * PRECISION) / 1e8;
	uint256 public ALTERNATIVE_INTEREST_RATE = (3 * PRECISION) / 1e8;

	// Contracts
	Token public sepoliaToken;
	Token public baseSepoliaToken;
	Vault public sepoliaVault;
	Vault public baseSepoliaVault;
	CustomTokenPool public sepoliaCustomTokenPool;
	CustomTokenPool public baseSepoliaCustomTokenPool;

	// Network details
	Register.NetworkDetails public sepoliaNetworkDetails;
	Register.NetworkDetails public baseSepoliaNetworkDetails;

	// Forks
	uint256 public SEPOLIA_FORK;
	uint256 public BASE_SEPOLIA_FORK;

	CCIPLocalSimulatorFork public ccipLocalSimulatorFork;


	function setUp() public {
		SEPOLIA_FORK = vm.createSelectFork("sepolia"); // Chose Sepolia fork
		BASE_SEPOLIA_FORK = vm.createFork("base-sepolia");
		ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
		vm.makePersistent(address(ccipLocalSimulatorFork));

		vm.deal(OWNER, OWNER_INITIAL_BALANCE);
		vm.deal(USER_1, USER_1_INITIAL_BALANCE);
		vm.deal(USER_2, USER_2_INITIAL_BALANCE);
		ccipLocalSimulatorFork.requestLinkFromFaucet(USER_1, USER_1_INITIAL_BALANCE);
		ccipLocalSimulatorFork.requestLinkFromFaucet(USER_2, USER_2_INITIAL_BALANCE);

		// Get network details
		vm.selectFork(SEPOLIA_FORK);
		sepoliaNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);
		vm.selectFork(BASE_SEPOLIA_FORK);
		baseSepoliaNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);

		// Deploy for Sepolia
		vm.selectFork(SEPOLIA_FORK);
		vm.startPrank(OWNER);
			sepoliaToken = new Token();
			sepoliaVault = new Vault(IToken(address(sepoliaToken)));
			sepoliaToken.grantMintAndBurnRole(address(sepoliaVault));
			payable(address(sepoliaVault)).call{value: VAULT_INITIAL_BALANCE}("");
			sepoliaCustomTokenPool = new CustomTokenPool(IERC20(address(sepoliaToken)), new address[](0), sepoliaNetworkDetails.rmnProxyAddress, sepoliaNetworkDetails.routerAddress);

			sepoliaToken.grantMintAndBurnRole(address(sepoliaVault));
			sepoliaToken.grantMintAndBurnRole(address(sepoliaCustomTokenPool));
			RegistryModuleOwnerCustom(sepoliaNetworkDetails.registryModuleOwnerCustomAddress).registerAdminViaOwner(address(sepoliaToken));
			TokenAdminRegistry(sepoliaNetworkDetails.tokenAdminRegistryAddress).acceptAdminRole(address(sepoliaToken));
			TokenAdminRegistry(sepoliaNetworkDetails.tokenAdminRegistryAddress).setPool(address(sepoliaToken), address(sepoliaCustomTokenPool));
		vm.stopPrank();


		// Deploy for Base Sepolia
		vm.selectFork(BASE_SEPOLIA_FORK);

		vm.deal(OWNER, OWNER_INITIAL_BALANCE);
		vm.deal(USER_1, USER_1_INITIAL_BALANCE);
		vm.deal(USER_2, USER_2_INITIAL_BALANCE);
		ccipLocalSimulatorFork.requestLinkFromFaucet(USER_1, USER_1_INITIAL_BALANCE);
		ccipLocalSimulatorFork.requestLinkFromFaucet(USER_2, USER_2_INITIAL_BALANCE);

		vm.startPrank(OWNER);
			baseSepoliaToken = new Token();
			baseSepoliaVault = new Vault(IToken(address(baseSepoliaToken)));
			baseSepoliaToken.grantMintAndBurnRole(address(baseSepoliaVault));
			payable(address(baseSepoliaVault)).call{value: VAULT_INITIAL_BALANCE}("");
			baseSepoliaCustomTokenPool = new CustomTokenPool(IERC20(address(baseSepoliaToken)), new address[](0), baseSepoliaNetworkDetails.rmnProxyAddress, baseSepoliaNetworkDetails.routerAddress);

			baseSepoliaToken.grantMintAndBurnRole(address(baseSepoliaVault));
			baseSepoliaToken.grantMintAndBurnRole(address(baseSepoliaCustomTokenPool));
			RegistryModuleOwnerCustom(baseSepoliaNetworkDetails.registryModuleOwnerCustomAddress).registerAdminViaOwner(address(baseSepoliaToken));
			TokenAdminRegistry(baseSepoliaNetworkDetails.tokenAdminRegistryAddress).acceptAdminRole(address(baseSepoliaToken));
			TokenAdminRegistry(baseSepoliaNetworkDetails.tokenAdminRegistryAddress).setPool(address(baseSepoliaToken), address(baseSepoliaCustomTokenPool));
		vm.stopPrank();
	}


	function configureTokenPool(uint256 fork, address localPool, address remotePool, address remoteToken, uint64 remoteChainSelector) public {
		vm.selectFork(fork);

		bytes[] memory remotePoolAddresses = new bytes[](1);
		remotePoolAddresses[0] = abi.encode(remotePool);

		TokenPool.ChainUpdate[] memory chainsToAdd = new TokenPool.ChainUpdate[](1);
		chainsToAdd[0] = TokenPool.ChainUpdate({
			remoteChainSelector: remoteChainSelector,
			remotePoolAddresses: remotePoolAddresses,
			remoteTokenAddress: abi.encode(remoteToken),
			outboundRateLimiterConfig: RateLimiter.Config({
				isEnabled: false,
				capacity: 0,
				rate: 0
			}),
			inboundRateLimiterConfig: RateLimiter.Config({
				isEnabled: false,
				capacity: 0,
				rate: 0
			})
		});

		vm.startPrank(OWNER);
			TokenPool(localPool).applyChainUpdates(new uint64[](0), chainsToAdd);
		vm.stopPrank();
	}


	function bridgeTokens(uint256 amount, uint256 localFork, uint256 remoteFork, Register.NetworkDetails memory localNetworkDetails, Register.NetworkDetails memory remoteNetworkDetails, Token localToken, Token remoteToken) public {
		Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
		tokenAmounts[0] = Client.EVMTokenAmount({
			token: address(localToken),
			amount: amount
		});

		Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
			receiver: abi.encode(USER_1),
			data: "",
			tokenAmounts: tokenAmounts,
			feeToken: localNetworkDetails.linkAddress,
			extraArgs: ""
		});

		uint256 fee = IRouterClient(localNetworkDetails.routerAddress).getFee(remoteNetworkDetails.chainSelector, message);
		IERC20(localNetworkDetails.linkAddress).approve(localNetworkDetails.routerAddress, fee);
		IERC20(address(localToken)).approve(localNetworkDetails.routerAddress, amount);

		IRouterClient(localNetworkDetails.routerAddress).ccipSend(remoteNetworkDetails.chainSelector, message);
	}


	function testBridgeTokens(uint256 amount) public {

		// — Configure pools —
		vm.selectFork(SEPOLIA_FORK);
		configureTokenPool(SEPOLIA_FORK, address(sepoliaCustomTokenPool), address(baseSepoliaCustomTokenPool), address(baseSepoliaToken), baseSepoliaNetworkDetails.chainSelector);
		vm.selectFork(BASE_SEPOLIA_FORK);
		configureTokenPool(BASE_SEPOLIA_FORK, address(baseSepoliaCustomTokenPool), address(sepoliaCustomTokenPool), address(sepoliaToken), sepoliaNetworkDetails.chainSelector);

		// — Testing —
		vm.selectFork(SEPOLIA_FORK);
		uint256 boundedAmount = bound(amount, 1 gwei, 1 ether);
		
		vm.startPrank(USER_1);
			sepoliaVault.deposit{value: boundedAmount}();
			bridgeTokens(boundedAmount, SEPOLIA_FORK, BASE_SEPOLIA_FORK, sepoliaNetworkDetails, baseSepoliaNetworkDetails, sepoliaToken, baseSepoliaToken);
		vm.stopPrank();

		vm.warp(block.timestamp + 1 hours);
		uint256 localBalanceAfter = sepoliaToken.balanceOf(USER_1);
		uint256 localInterestRate = sepoliaToken.s_accountToInterestRate(USER_1);
		assertEq(localBalanceAfter, 0);

		vm.selectFork(SEPOLIA_FORK);
		ccipLocalSimulatorFork.switchChainAndRouteMessage(BASE_SEPOLIA_FORK);
		vm.selectFork(BASE_SEPOLIA_FORK);
		uint256 remoteBalanceAfter = baseSepoliaToken.balanceOf(USER_1);
		uint256 remoteInterestRate = baseSepoliaToken.s_accountToInterestRate(USER_1);
		assertEq(remoteBalanceAfter, boundedAmount);

		assertEq(localInterestRate, remoteInterestRate);
	}
}