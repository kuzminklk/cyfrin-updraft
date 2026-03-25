

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { MessageSender } from "../src/ccip/MessageSender.sol";
import { Script } from "forge-std/Script.sol";


contract DeployMessageSender is Script {
	function run() external {
		vm.startBroadcast();

		new MessageSender();

		vm.stopBroadcast();
	}
}