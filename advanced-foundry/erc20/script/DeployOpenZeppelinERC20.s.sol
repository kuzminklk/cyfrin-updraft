

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { KBYN } from "../src/OpenZeppelinERC20.sol";
import { Script } from "forge-std/Script.sol";


contract DeployOpenZeppelinERC20 is Script {
	function run() external returns (KBYN) {
		vm.startBroadcast();

		KBYN KBYNContract = new KBYN(100 ether);

		vm.stopBroadcast();

		return KBYNContract;
	}
}