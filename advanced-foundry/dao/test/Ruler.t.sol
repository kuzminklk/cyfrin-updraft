

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import { Test, console } from "forge-std/Test.sol";

import { Value } from "../src/Value.sol";
import { GovernanceToken } from "../src/GovernanceToken.sol";
import { Ruler } from "../src/Ruler.sol";
import { TimeLock } from "../src/TimeLock.sol";
import { Deploy } from "../script/Deploy.s.sol";


/**
	* @notice Test governor contract aka “Ruler” and general DAO functionality
	*/
contract RulerTest is Test {
	uint256 constant public VALUE_TO_STORE = 100;
	uint256 constant public AMOUNT_OF_ETHERS_TO_SEND = 0;
	uint256 constant public TIMELOCK_DELAY = 50400; // In blocks, equal 1 week with 15 seconds block time
	uint256 constant public VOTING_DELAY = 7200; // In blocks, equal 1 day with 15 seconds block time
	uint256 constant public VOTING_PERIOD = 50400; // In blocks, equal 1 week with 15 seconds block time

	Value public valueContract;
	GovernanceToken public governanceTokenContract;
	Ruler public rulerContract;
	TimeLock public timeLockContract;
	Deploy public deployer;

	address owner;

	address[] public targets;
	uint256[] public values;
	bytes[] public calldatas;

	function setUp() public {
		owner = makeAddr("owner");
		console.log(unicode"“owner” for “setUp” is: %s", owner);
		console.log(unicode"“msg.sender” for “setUp” is: %s", msg.sender);
		console.log(unicode"“tx.origin” for “setUp” is: %s", tx.origin);

		deployer = new Deploy();

		vm.startPrank(owner, owner);
			(valueContract, governanceTokenContract, rulerContract, timeLockContract) = deployer.deploy(owner);
		vm.stopPrank();
	}

	/**
	 * @notice Test that value can't be set outside
	 */
	function testCantUpdateValueWithoutGovernance() public {
		vm.expectRevert();
		valueContract.setValue(VALUE_TO_STORE);
	}

	/**
	 * @notice Test that value can be set from governance (“Ruler” contract)
	 */
	function testCanUpdateValueWithGovernance() public {

		// 1. Create porposal
		string memory description = "Store 100 in the Value contract";
		bytes memory encodedFunctionCall = abi.encodeWithSignature("setValue(uint256)", VALUE_TO_STORE);

		targets.push(address(valueContract));
		values.push(AMOUNT_OF_ETHERS_TO_SEND);
		calldatas.push(encodedFunctionCall);

		// 2. Send porpose to the DAO
		uint256 proposalIdentificator = rulerContract.propose(targets, values, calldatas, description);

		vm.warp(block.timestamp + VOTING_DELAY + 1);
		vm.roll(block.number + VOTING_DELAY + 1);

		// 3. Vote for porposal
		string memory reason = "Because it's cool!";
		uint8 vote = 1; // Equal “For” for approprate enum
		vm.startPrank(owner);
			rulerContract.castVoteWithReason(proposalIdentificator, vote, reason);
		vm.stopPrank();

		vm.warp(block.timestamp + VOTING_PERIOD + 1);
		vm.roll(block.number + VOTING_PERIOD + 1);

		// 4. Queue
		bytes32 descriptionHash = keccak256(abi.encodePacked(description));
		rulerContract.queue(targets, values, calldatas, descriptionHash);

		vm.warp(block.timestamp + TIMELOCK_DELAY + 1);
		vm.roll(block.number + TIMELOCK_DELAY + 1);

		// 5. Execute
		rulerContract.execute(targets, values, calldatas, descriptionHash);

		// 6. Assert
		assertEq(valueContract.s_value(), VALUE_TO_STORE);
	}
}