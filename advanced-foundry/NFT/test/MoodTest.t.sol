

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { Mood } from "../src/Mood.sol";
import { DeployMood } from "../script/DeployMood.s.sol";

import { console, Test } from "forge-std/Test.sol";


contract TestMood is Test {
	DeployMood public deployer;
	Mood public MoodContract;
	address public USER = makeAddr("User");

	function setUp() public {
		deployer = new DeployMood();
		MoodContract = deployer.run();
	}

	function testURI() public {
		vm.prank(USER);
		MoodContract.mint();
		console.log(MoodContract.tokenURI(0));
	}

	function testFlipMood() public {
		string memory SAD_SVG_URI = vm.readFile("./uri/sad.txt");

		vm.prank(USER);
		MoodContract.mint();

		vm.prank(USER);
		MoodContract.flipMood(0);

		assertEq(MoodContract.imageURI(0), SAD_SVG_URI);
	}
}