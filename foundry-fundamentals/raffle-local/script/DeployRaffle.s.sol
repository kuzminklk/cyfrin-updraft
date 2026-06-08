

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19; 

import { Script } from "forge-std/Script.sol";

import { Raffle } from "src/Raffle.sol";
import { HelperConfig } from "script/HelperConfig.s.sol";
import { CreateSubscription, FundSubscription, AddConsumer } from "script/Interactions.s.sol";


contract DeployRaffle is Script {

	function run() public {
		deployContract();
	}

	function deployContract() public returns(Raffle, HelperConfig) {
		HelperConfig configContract = new HelperConfig();
		/* 
		For local (Anvil): deploy mocks, get local config.
		For Sepolia: get Sepolia config.
		*/
		HelperConfig.NetworkConfig memory networkConfig = configContract.getNetworkConfig();

		if(networkConfig.subscriptionId == 0) {
			CreateSubscription createSubscriptionContract = new CreateSubscription();(networkConfig.subscriptionId, ) = createSubscriptionContract.createSubscription(networkConfig.vrfCoordinatorContract, networkConfig.account);

			FundSubscription fundSubscriptionContract = new FundSubscription();
			fundSubscriptionContract.fundSubscription(networkConfig.vrfCoordinatorContract, networkConfig.subscriptionId, networkConfig.linkTokenContract, networkConfig.account);
		}

		vm.startBroadcast(networkConfig.account);
			Raffle raffle = new Raffle(
				networkConfig.entranceFee,
				networkConfig.interval,
				networkConfig.vrfCoordinatorContract,
				networkConfig.subscriptionId,
				networkConfig.gasLane,
				networkConfig.callbackGasLimit
			);
		vm.stopBroadcast();

		AddConsumer addConsumerContract = new AddConsumer();
		addConsumerContract.addConsumer(address(raffle), networkConfig.vrfCoordinatorContract, networkConfig.subscriptionId,  networkConfig.account);

		return(raffle, configContract);
	}
}

