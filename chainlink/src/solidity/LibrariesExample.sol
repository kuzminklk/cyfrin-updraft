

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { MathUtilities } from "./LibrariesAndInheritance.sol";


contract Calculator {
	using MathUtilities for uint256;

	function getMinimum(uint256 a, uint256 b) public pure returns (uint256) {
		return MathUtilities.min(a, b);
		/* 
		Or 
			return a.min(b); 
		*/
	}
}