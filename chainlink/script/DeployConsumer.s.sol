

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Consumer } from "../src/functions/Consumer.sol";
import { Script } from "forge-std/Script.sol";


contract DeployConsumer is Script {
	function run() external {
		vm.startBroadcast();

		new Consumer();

		vm.stopBroadcast();
	}
}