

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import { Script } from "forge-std/Script.sol";
import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { Token } from "../src/Token.sol";
import { Airdrop } from "../src/Airdrop.sol";


contract Deploy is Script {
	Token public token;
	Airdrop public airdrop;

	bytes32 constant public MERKLE_ROOT = 0x4bd9749690341b06f02c1683c9c74eb3aaf5c745e5c1ab0e58d2ddeca74667d0;
	uint256 immutable public INITIAL_SUPPLY = 1000e18; // 1000 tokens with 1e18 precision

	function deploy() public returns(Token, Airdrop) {
		vm.startBroadcast();
			token = new Token();
			airdrop = new Airdrop(MERKLE_ROOT, IERC20(address(token)));
			token.transfer(address(airdrop), INITIAL_SUPPLY);
		vm.stopBroadcast();
		return (token, airdrop);
	}

	function run() external {
	}
}