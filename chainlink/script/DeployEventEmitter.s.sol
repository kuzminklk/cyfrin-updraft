

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { EventEmitter } from "../src/automation/EventEmitter.sol";
import { Script } from "forge-std/Script.sol";


contract DeployEventEmitter is Script {
	function run() external {
		vm.startBroadcast();

		new EventEmitter();

		vm.stopBroadcast();
	}
}