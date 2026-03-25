

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { MessageReciver } from "../src/ccip/MessageReciver.sol";
import { Script } from "forge-std/Script.sol";


contract DeployMessageReciver is Script {
	function run() external {
		vm.startBroadcast();

		new MessageReciver();

		vm.stopBroadcast();
	}
}