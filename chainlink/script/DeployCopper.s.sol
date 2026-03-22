

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Copper } from "../src/solidity/ERC20.sol";
import { Script } from "forge-std/Script.sol";


contract DeployCopper is Script {
	function run() external {
		vm.startBroadcast();

		new Copper();

		vm.stopBroadcast();
	}
}