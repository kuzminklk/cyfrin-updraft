

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { Flowers } from "../src/Flowers.sol";
import { DeployFlowers } from "../script/DeployFlowers.s.sol";

import { Test } from "forge-std/Test.sol";


contract TestFlowers is Test {
	DeployFlowers public deployer;
	Flowers public flowersContract;
	address public USER = makeAddr("User");
	string public PINK_ROSE_URI = "ipfs://QmUdboJc9a49cUsJUmjWTk6hNeeJJ6tChKBGHEGLJwxD2a";

	function setUp() public {
		deployer = new DeployFlowers();
		flowersContract = deployer.run();
	}

	function testNameIsCorrect() public {
		string memory expectedName = "Flowers";
		string memory actualName = flowersContract.name();
		assertEq(keccak256(bytes(expectedName)), keccak256(bytes(actualName)));
	}

	function testCanMint() public {
		vm.prank(USER);
		flowersContract.mint(PINK_ROSE_URI);

		assert(flowersContract.balanceOf(USER) == 1);
		assertEq(keccak256(bytes(PINK_ROSE_URI)), keccak256(bytes(flowersContract.tokenURI(0))));
	}
}