

// SPDX-License-Identifier: MIT  

pragma solidity ^0.8.26;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract KBYN is ERC20 {
	constructor(uint256 initialSupply) ERC20("Kuzmin's Company Tokenized BYN", "KBYN") {
		_mint(msg.sender, initialSupply);
	}
}