

// SPDX-License-Identifier: MIT  

pragma solidity ^0.8.26;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";


contract Token is ERC20, Ownable {
	uint256 immutable public INITIAL_SUPPLY = 1000 * 10 ** decimals();

	constructor() ERC20("Strawberry", "STRAWBERRY") Ownable(msg.sender) {
		_mint(msg.sender, INITIAL_SUPPLY);
	}
	
}