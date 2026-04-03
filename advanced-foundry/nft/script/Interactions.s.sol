

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { Flowers } from "../src/Flowers.sol";

import { Script } from "forge-std/Script.sol";
import { DevOpsTools } from "lib/foundry-devops/src/DevOpsTools.sol";


contract MintPinkRose is Script {
	string public PINK_ROSE_URI = "ipfs://QmUdboJc9a49cUsJUmjWTk6hNeeJJ6tChKBGHEGLJwxD2a";

	function run() external {
		address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Flowers", block.chainid);

		vm.startBroadcast();
			Flowers(mostRecentlyDeployed).mint(PINK_ROSE_URI);
		vm.stopBroadcast();
	}
}