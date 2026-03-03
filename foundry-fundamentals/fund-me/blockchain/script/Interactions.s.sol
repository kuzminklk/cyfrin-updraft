

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";
import { DevOpsTools } from "../lib/foundry-devops/src/DevOpsTools.sol";

import { FundMe } from "../src/FundMe.sol";


contract Fund is Script {
		
	uint256 constant TEST_SEND_VALUE = 0.1 ether;

	function fund(address fundMe) public {
		FundMe(payable(fundMe)).fund{value: TEST_SEND_VALUE}();
	}

	function run() external {
		address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

		vm.startBroadcast();
		fund(mostRecentlyDeployed);
		vm.stopBroadcast();
	}

}

contract Withdraw is Script {
				
	uint256 constant TEST_SEND_VALUE = 0.1 ether;

	function withdraw(address fundMe) public {
		FundMe(payable(fundMe)).withdraw();
	}

	function run() external {
		address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

		vm.startBroadcast();
		withdraw(mostRecentlyDeployed);
		vm.stopBroadcast();
	}

}