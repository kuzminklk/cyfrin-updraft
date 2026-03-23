

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Counter } from "../src/automation/EventCounter.sol";
import { Script } from "forge-std/Script.sol";


contract DeployEventCounter is Script {
	function run() external {
		vm.startBroadcast();

		new Counter();

		vm.stopBroadcast();
	}
}