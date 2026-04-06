


/* 
Layout of test sections:
1. Deposit
2. Mint Stablecoins
3. Collateral (Calculate, Redeem)
4. Burn Stablecoins
5. Health Factor
6. Liquidation
*/



// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { Engine } from "../../src/Engine.sol";
import { Stablecoin } from "../../src/Stablecoin.sol";
import { DeploySystem } from "../../script/DeploySystem.s.sol";
import { HelperConfig } from "../../script/HelperConfig.s.sol";

import { console, Test } from "forge-std/Test.sol";
import { ERC20Mock } from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";


contract TestEngine is Test {

	uint256 public constant USER_COLLATERAL_AMOUNT = 10 ether; // Equal 20,000$
	uint256 public constant USER_MINTED_STABLECOINS = 4000 ether; // Equal 4,000$
	uint256 public constant USER_WETH_BALANCE = 100 ether;
	address public USER = makeAddr("User");

	DeploySystem public deployer;
	HelperConfig public config;
	Engine public engineContract;
	Stablecoin public stablecoinContract;

	address wethToUsdPriceFeed;
	address wbtcToUsdPriceFeed;
	address weth;
	address wbtc;

	function setUp() public {
		deployer = new DeploySystem();
		(stablecoinContract, engineContract, config) = deployer.run();
		(wethToUsdPriceFeed, wbtcToUsdPriceFeed, weth, wbtc) = config.activeNetworkConfig();

		ERC20Mock(weth).mint(USER, USER_WETH_BALANCE);
	}

	// — Collateral (Calculate, Redeem) —

	function testGetValueInUSD() public {
		uint256 etherAmount = 10 ether; // Equal 10e18
		// Example: 10e18 * 2,000 = 20,000e18 
		uint256 expectedValueInUSD = 20000e18;
		uint256 actualValueInUSD = engineContract.getValueInUSD(weth, etherAmount);
		assertEq(expectedValueInUSD, actualValueInUSD);
	}

	// — Deposit  —

	function testRevertsIfCollateralIsZero() public {
		vm.startPrank(USER);
			ERC20Mock(weth).approve(address(engineContract), USER_COLLATERAL_AMOUNT);

			vm.expectRevert(Engine.Engine__AmountMustBeGreaterThanZero.selector);
			engineContract.depositCollateral(weth, 0);
		vm.stopPrank();
	}

	// — Health Factor —

	function testHealthFactor() public {
		/* Test logic:
		Collateral is 10wETH (20,000$), minted Stablecoins are 4000$.
		Health factor 20,000 / (4,000 + 400(liquidation buffer)) = 4.54… ~= 4 */
		vm.startPrank(USER);
			ERC20Mock(weth).approve(address(engineContract), USER_COLLATERAL_AMOUNT);
			engineContract.depositCollateral(weth, USER_COLLATERAL_AMOUNT);
			engineContract.mintStablecoins(USER_MINTED_STABLECOINS);
			assertEq(engineContract.getHealthFactor(USER), 4);
		vm.stopPrank();
	}
}