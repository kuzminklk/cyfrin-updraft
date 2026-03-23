

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { TokenSender } from "../src/ccip/TokenSender.sol";
import { Script } from "forge-std/Script.sol";


contract DeployTokenSender is Script {
	function run() external {
		vm.startBroadcast();

		new TokenSender();

		vm.stopBroadcast();
	}
}