

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Test } from "forge-std/Test.sol";

import { FundMe } from "../../src/FundMe.sol";
import { Deploy } from "../../script/Deploy.s.sol";


contract FundMeTestIntegration is Test {

	FundMe fundMe;

	uint256 constant TEST_SEND_VALUE = 0.1 ether;
	uint256 constant TEST_STARTING_BALANCE = 10 ether;
	address immutable USER = makeAddr("user");

	function setUp() external {
		Deploy deploy = new Deploy();
		fundMe = deploy.run();
		vm.deal(USER, TEST_STARTING_BALANCE);
	}

	function testUserCanFund() public {
		vm.prank(USER);
		fundMe.fund{value: TEST_SEND_VALUE}();
		address funder = fundMe.sFunders(0);
		assertEq(funder, address(USER));
	}

	function testOwnerCanWithdraw() public {
		vm.prank(fundMe.OWNER());
		fundMe.withdraw();
		assertEq(address(fundMe).balance, 0);
	}
}