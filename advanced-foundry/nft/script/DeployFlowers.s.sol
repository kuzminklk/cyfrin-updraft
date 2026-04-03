

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { Flowers } from "../src/Flowers.sol";
import { Script } from "forge-std/Script.sol";


contract DeployFlowers is Script {
	function run() external returns (Flowers) {
		vm.startBroadcast();

		Flowers FlowersContract = new Flowers();

		vm.stopBroadcast();

		return FlowersContract;
	}
}