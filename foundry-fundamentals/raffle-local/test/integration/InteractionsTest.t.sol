

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19; 

import { Test } from "forge-std/Test.sol";

import { Raffle } from "src/Raffle.sol";
import { DeployRaffle } from "script/DeployRaffle.s.sol";
import { CreateSubscription, FundSubscription, AddConsumer } from "script/Interactions.s.sol";
import { HelperConfig, Constants } from "script/HelperConfig.s.sol";


contract InteractionsTest is Test, Constants {
	Raffle public raffle;
	HelperConfig public helperConfig;
	HelperConfig.NetworkConfig public networkConfig;

	function setUp() public {
		// vm.deal(TEST_USER, TEST_STARTING_BALANCE);
	}

	function testDeployIsWorking() public {
		DeployRaffle deployer = new DeployRaffle();
		(raffle, helperConfig) = deployer.deployContract();
		networkConfig = helperConfig.getNetworkConfig();
	}
}