

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { HousePicker } from "../src/vrf/HousePicker.sol";
import { Script } from "forge-std/Script.sol";


contract DeployHousePicker is Script {
	function run() external {
		vm.startBroadcast();

		new HousePicker(44878275500697549577780144414792965797978387141563735737188503673385504209106);

		vm.stopBroadcast();
	}
}