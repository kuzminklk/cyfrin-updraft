

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Counter } from "../src/automation/CounterWithCustomLogic.sol";
import { Script } from "forge-std/Script.sol";


contract DeployCounter is Script {
	function run() external {
		vm.startBroadcast();

		new Counter(300);

		vm.stopBroadcast();
	}
}