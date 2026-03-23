

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Market } from "../src/data-feeds/Market.sol";
import { Script } from "forge-std/Script.sol";


contract DeployMarket is Script {

	address public constant TOKEN_ADDRESS = 0x1A0D56B0772327358C8a6478B764Db65B081f5e5;

	function run() external {
		vm.startBroadcast();

		new Market(TOKEN_ADDRESS);

		vm.stopBroadcast();
	}
}