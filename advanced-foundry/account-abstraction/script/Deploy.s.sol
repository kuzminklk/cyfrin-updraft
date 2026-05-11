

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import { Script } from "forge-std/Script.sol";

import { Account as AccountAbstraction } from "../src/ethereum/Account.sol"; // Use alias because Account is an struct from forge-std/Script.sol …
import { Configuration } from "./Configuration.s.sol";


contract Deploy is Script {

	function run() public {
		vm.startBroadcast();
			deploy();
		vm.stopBroadcast();
	}

	/**
	 * @notice Deploy «Account» with appropriate «EntryPoint» for that chain
	 */
	function deploy() public returns (Configuration, AccountAbstraction) {
		Configuration configuration = new Configuration();
		Configuration.NetworkConfiguration memory networkConfiguration = configuration.getNetworkConfiguration();

		AccountAbstraction accountAbstractionContract = new AccountAbstraction(networkConfiguration.entryPoint);

		return (configuration, accountAbstractionContract);
	}
}