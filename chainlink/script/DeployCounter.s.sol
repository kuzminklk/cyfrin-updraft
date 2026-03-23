

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Counter } from "../src/automation/Counter.sol";
import { Script } from "forge-std/Script.sol";


contract DeployCounter is Script {
	function run() external {
		vm.startBroadcast();

		new Counter();

		vm.stopBroadcast();
	}
}