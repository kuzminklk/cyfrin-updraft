

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Test } from "forge-std/Test.sol";

import { FundMe } from "../../src/FundMe.sol";
import { Deploy } from "../../script/Deploy.s.sol";


contract FundMeTest is Test {

	FundMe fundMe;

	uint256 constant TEST_SEND_VALUE = 0.1 ether;
	uint256 constant TEST_STARTING_BALANCE = 10 ether;
	address immutable USER = makeAddr("user");

	function setUp() external {
		Deploy deploy = new Deploy();
		fundMe = deploy.run();
		vm.deal(USER, TEST_STARTING_BALANCE);
	}


	// Test contract construction ( constructor() )

	function testOwnerIsMessageSender() public view {
		assertEq(fundMe.OWNER(), msg.sender);
	}


	// Test funding functionality ( fund() )

	function testMinimumAmountIsFiveDollars() public view {
		assertEq(fundMe.MINIMUM_USD(), 5e18);
	}

	function testFundsFailWithoutEnoughAmount() public {
		vm.expectRevert();
		fundMe.fund();
	}

	function testFundsUpdatesData() public funded {
		uint256 amountFunded = fundMe.sAddressToAmountFunded(USER);
		assertEq(amountFunded, TEST_SEND_VALUE);
	}

	function testAddsFunderToArray() public funded {
		address funder = fundMe.sFunders(0);
		assertEq(funder, USER);
	}


	// Test withdrawing functionality ( withdraw() )

	function testOnlyOwnerCanWithdraw() public funded {
		vm.expectRevert();
		vm.prank(USER);
		fundMe.withdraw();
	}

	function testWithdrawWithSingleFunder() public funded {
		// Arrange
		uint256 startingOwnerBalance = fundMe.OWNER().balance;
		uint256 startingFundMeBalance = address(fundMe).balance;

		// Act
		vm.prank(fundMe.OWNER());
		fundMe.withdraw();

		// Assert
		uint256 endingOwnerBalance = fundMe.OWNER().balance;
		uint256 endingFundMeBalance = address(fundMe).balance;
		assertEq(endingFundMeBalance, 0);
		assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
	}

	function testWithdrawWithMultipleFunders() public {

		// Arrange
		uint160 numberOfFunders = 10; // Will generate addresses from this
		uint160 staringFunderIndex = 1;
		for(uint160 i = staringFunderIndex; i < numberOfFunders; i++) {
			hoax(address(i), TEST_SEND_VALUE);
			fundMe.fund{value:TEST_SEND_VALUE}();
		}

		uint256 startingOwnerBalance = fundMe.OWNER().balance;
		uint256 startingFundMeBalance = address(fundMe).balance;

		// Act
		vm.prank(fundMe.OWNER());
		fundMe.withdraw();

		// Assert
		uint256 endingOwnerBalance = fundMe.OWNER().balance;
		uint256 endingFundMeBalance = address(fundMe).balance;
		assertEq(endingFundMeBalance, 0);
		assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
	}


	modifier funded() {
		vm.prank(USER);
		fundMe.fund{value: TEST_SEND_VALUE}();
		_;
	}

}