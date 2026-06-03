

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import { Script } from "forge-std/Script.sol";
import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { Token } from "../src/Token.sol";
import { Airdrop } from "../src/Airdrop.sol";


contract Deploy is Script {
	Token public token;
	Airdrop public airdrop;

	uint256 immutable public INITIAL_SUPPLY = 1000e18; // 1000 tokens with 1e18 precision

	function run(bytes32 _merkleRoot) public {
		deploy(_merkleRoot);
	}

	function deploy(bytes32 _merkleRoot) public returns(Token, Airdrop) {
		vm.startBroadcast();
			token = new Token();
			airdrop = new Airdrop(_merkleRoot, IERC20(address(token)));
			token.transfer(address(airdrop), INITIAL_SUPPLY);
		vm.stopBroadcast();
		return (token, airdrop);
	}
}