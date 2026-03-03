

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19; 

import { Script, console } from "forge-std/Script.sol";
import { VRFCoordinatorV2_5Mock } from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import { DevOpsTools } from "lib/foundry-devops/src/DevOpsTools.sol";

import { LinkToken } from "test/mocks/LinkToken.sol";
import { HelperConfig, Constants } from "script/HelperConfig.s.sol";




contract CreateSubscription is Script {
	function run() public {
		createSubscriptionUsingConfig();
	}

	function createSubscriptionUsingConfig() public returns(uint256, address) {
		HelperConfig helperConfig = new HelperConfig();
		address vrfCoordinatorContract = helperConfig.getNetworkConfig().vrfCoordinatorContract;

		address account = helperConfig.getNetworkConfig().account;

		return createSubscription(vrfCoordinatorContract, account);
	}

	function createSubscription(address vrfCoordinatorContract, address account) public returns(uint256, address) {
		console.log("Creating subscription on chain Id: ", block.chainid);

		vm.startBroadcast(account);
			uint256 subscriptionId = VRFCoordinatorV2_5Mock(vrfCoordinatorContract).createSubscription();
		vm.stopBroadcast();

		console.log("Your subscription Id is: ", subscriptionId);

		return(subscriptionId, vrfCoordinatorContract);
	}
}


contract FundSubscription is Script, Constants {

	function run() public {
		fundSubscritionUsingConfig();
	}

	function fundSubscritionUsingConfig() public {
		HelperConfig helperConfig = new HelperConfig();
		HelperConfig.NetworkConfig memory networkConfig = helperConfig.getNetworkConfig();
		address vrfCoordinatorContract = networkConfig.vrfCoordinatorContract;
		uint256 subscriptionId = networkConfig.subscriptionId;
		address linkTokenContract = networkConfig.linkTokenContract;
		address account = networkConfig.account;
		fundSubscription(vrfCoordinatorContract, subscriptionId, linkTokenContract, account);
	}

	function fundSubscription(address vrfCoordinatorContract, uint256 subscriptionId, address linkTokenContract, address account) public {
		console.log("Funding subscription: ", subscriptionId);
		console.log("Using vrfCoordinator Contract: ", vrfCoordinatorContract);
		console.log("On chain id: ", block.chainid);

		if(block.chainid == ANVIL_CHAIN_ID) {
			vm.startBroadcast();
				VRFCoordinatorV2_5Mock(vrfCoordinatorContract).fundSubscription(subscriptionId, SUBSCRIPTION_FUND_AMOUT * 100);
			vm.stopBroadcast();
		} else {
			vm.startBroadcast(account);
				LinkToken(linkTokenContract).transferAndCall(vrfCoordinatorContract, SUBSCRIPTION_FUND_AMOUT, abi.encode(subscriptionId));
			vm.stopBroadcast();
		}
	}
}


contract AddConsumer is Script {
	function run() public {
		address mostRecentlyDeployed = 	DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);

		addConsumerUsingConfig(mostRecentlyDeployed);
	}

	function addConsumerUsingConfig(address mostRecentlyDeployed) public {
		HelperConfig helperConfig = new HelperConfig();
		HelperConfig.NetworkConfig memory networkConfig = helperConfig.getNetworkConfig();
		address vrfCoordinatorContract = networkConfig.vrfCoordinatorContract;
		uint256 subscriptionId = networkConfig.subscriptionId;
		address account = networkConfig.account;

		addConsumer(mostRecentlyDeployed , vrfCoordinatorContract, subscriptionId, account);
	}

	function addConsumer(address contractToAddToCoordinator, address vrfCoordinatorContract, uint256 subscriptionId, address account) public {
		console.log("Adding consumer: ", contractToAddToCoordinator);
		console.log("To VRF Coordinator: ", vrfCoordinatorContract);
		console.log("On chain id: ", block.chainid);

		vm.startBroadcast(account);
			VRFCoordinatorV2_5Mock(vrfCoordinatorContract).addConsumer(subscriptionId, contractToAddToCoordinator);
		vm.stopBroadcast();
	}
}