

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


// ——— Libraries ———

library MathUtilities {
	function min(uint256 a, uint256 b) internal pure returns (uint256) {
		return a < b ? a : b;
	}

	function max(uint256 a, uint256 b) internal pure returns (uint256) {
		return a > b ? a : b;
	}
}


// ——— Inheritance ———

// — Basic — 
contract Token {
	string public name;
	uint256 public totalSupply;

	constructor(string memory _name) {
		name = _name;
		totalSupply = 1000000;
	}

	function getInfo() public virtual view returns (string memory) {
		return string.concat("Token: ", name);
	}
}

contract Gold is Token {
	constructor() Token("Gold") {}

	function getSymbol() public pure returns (string memory) {
		return "GOLD";
	}

	function getInfo() public override view returns (string memory) {
		return string.concat(super.getInfo(),"RWA Gold Token");
	}
}

// — From OpenZeppelin contracts — 
contract Silver is ERC20 {
	constructor() ERC20("Silver", "SILVER") {
		_mint(msg.sender, 1000000 * 10**18);
	}

	function burn(uint256 amount) public {
		_burn(msg.sender, amount);
	}
}

contract Pyramid is ERC20 {
	address public feeCollector;

	constructor(address _feeCollector) ERC20("Pyramid", "PYRAMID") {
		feeCollector = _feeCollector;
		_mint(msg.sender, 1000000 * 10**18);
	}

	function transfer(address to, uint256 amount) public override returns (bool) {
		uint256 fee = amount / 100;
		uint256 amountToTransfer = amount - fee;

		super.transfer(feeCollector, fee);

		return super.transfer(to, amountToTransfer);
	}
}