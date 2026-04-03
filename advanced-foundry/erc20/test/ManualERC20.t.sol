

// SPDX-License-Identifier: MIT  

pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import { KBYN } from "../src/ManualERC20.sol";
import { DeployManualERC20 } from "../script/DeployManualERC20.s.sol";


contract ManualERC20Test is Test {
	KBYN public KBYNContract;
	DeployManualERC20 public deployer;

	address bob = makeAddr("Bob");
	address alice = makeAddr("Alice");

	uint8 constant DECIMALS = 6;
	uint256 constant STARTING_BALANCE = 100 * 10 ** DECIMALS;

	function setUp() public {
		deployer = new DeployManualERC20();
		KBYNContract = deployer.run();

		vm.prank(msg.sender);
		KBYNContract.transfer(bob, STARTING_BALANCE);
	}

	function testBobBalance() public {
		assertEq(STARTING_BALANCE, KBYNContract.balanceOf(bob));
	}
	
}