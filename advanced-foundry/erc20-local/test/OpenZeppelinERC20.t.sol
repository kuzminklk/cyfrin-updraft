

// SPDX-License-Identifier: MIT  

pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import { KBYN } from "../src/OpenZeppelinERC20.sol";
import { DeployOpenZeppelinERC20 } from "../script/DeployOpenZeppelinERC20.s.sol";


contract OpenZeppelinERC20Test is Test {
	KBYN public KBYNContract;
	DeployOpenZeppelinERC20 public deployer;

	address bob = makeAddr("Bob");
	address alice = makeAddr("Alice");

	uint8 constant DECIMALS = 6;
	uint256 constant STARTING_BALANCE = 10 ether;

	function setUp() public {
		deployer = new DeployOpenZeppelinERC20();
		KBYNContract = deployer.run();

		vm.prank(msg.sender);
		KBYNContract.transfer(bob, STARTING_BALANCE);
	}

	function testBobBalance() public {
		assertEq(STARTING_BALANCE, KBYNContract.balanceOf(bob));
	}

	function testAllowanceWorks() public {
		uint256 initialAllowance = 1 ether;

		vm.prank(bob);
		KBYNContract.approve(alice, initialAllowance);

		vm.prank(alice);
		KBYNContract.transferFrom(bob, alice, initialAllowance);

		assertEq(KBYNContract.balanceOf(alice), initialAllowance);
		assertEq(KBYNContract.balanceOf(bob), STARTING_BALANCE - initialAllowance);
	}
	
}