

// SPDX-License-Identifier: MIT  

pragma solidity ^0.8.26;


contract KBYN {

	error KBYN__NotEnoughtTokens();

	event Transfer();

	mapping(address => uint256) private s_balances;


	function name() public pure returns (string memory) {
		return "Kuzmin's Company Tokenized BYN";
	}

	function symbol() public pure returns (string memory) {
		return "KBYN";
	}

	function decimals() public pure returns (uint8) {
		return 6;
	}

	function totalSypply() public pure returns (uint256) {
		return 1000000000 * 10 ** decimals();
	}
	
	function balanceOf(address _owner) public view returns (uint256) {
		return s_balances[_owner];
	}

	function transfer(address _to, uint256 _amount) public returns (bool success) {

		// Checks
		if (s_balances[msg.sender] < _amount) {
			revert KBYN__NotEnoughtTokens();
		}

		// Effects
		s_balances[msg.sender] -= _amount;
		s_balances[_to] += _amount;

		// Interactions
		emit Transfer();
		success = true;
	}
}