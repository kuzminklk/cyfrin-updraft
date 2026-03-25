

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Vault } from "../src/ccip/Vault.sol";
import { Script } from "forge-std/Script.sol";


contract DeployVault is Script {
	function run() external {
		vm.startBroadcast();

		new Vault();

		vm.stopBroadcast();
	}
}