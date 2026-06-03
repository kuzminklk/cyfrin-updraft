

// SPDX-License-Identifier: MIT  

pragma solidity ^0.8.28;


import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";


/**
 * @notice Value storage
 */
contract Value is Ownable {
	uint256 public s_value;

	event ValueSet(uint256 number);
	
	constructor() Ownable(msg.sender) {

	}

	function setValue(uint256 _value) public onlyOwner {
		s_value = _value;
		emit ValueSet(_value);
	}
}