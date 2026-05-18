

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol"; 


/**
 * @notice Time lock for “Ruler”
 * @notice Create time space for users to exit DAO before porposal will be execute
 */
contract TimeLock is TimelockController {
	constructor(uint256 _mininalDelay, address[] memory _proposers, address[] memory _executors) TimelockController(_mininalDelay, _proposers, _executors, msg.sender) {}
}