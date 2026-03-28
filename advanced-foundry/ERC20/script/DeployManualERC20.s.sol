

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { KBYN } from "../src/ManualERC20.sol";
import { Script } from "forge-std/Script.sol";


contract DeployManualERC20 is Script {
	function run() external {
		vm.startBroadcast();

		new KBYN();

		vm.stopBroadcast();
	}
}