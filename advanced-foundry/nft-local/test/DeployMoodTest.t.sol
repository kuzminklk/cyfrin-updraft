

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { Mood } from "../src/Mood.sol";
import { DeployMood } from "../script/DeployMood.s.sol";

import { console, Test } from "forge-std/Test.sol";


contract TestDeployMood is Test {
	DeployMood public deployer;
	Mood public MoodContract;
	address public USER = makeAddr("User");

	function setUp() public {
		deployer = new DeployMood();
		MoodContract = deployer.run();
	}

	function testSvgToImageURI() public {
		string memory HAPPY_EMODJI_SVG_URI = vm.readFile("./uri/happy.txt");
		string memory SVG = vm.readFile("./images/happy.svg");

		assertEq(HAPPY_EMODJI_SVG_URI, deployer.svgToImageURI(SVG));
	}

}