

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { PriceConverter } from "./PriceConverter.sol";


error FundMe__NotOwner();
error FundMe__CallFailed();

contract FundMe {

	using PriceConverter for uint;

	uint public constant MINIMUM_USD = 5e18;

	address public immutable i_owner;

	address[] public funders;
	mapping(address funder => uint amountFunded) public addressToAmountFunded;

	constructor() {
		i_owner = msg.sender;
	}

	function fund() public payable {
		require(msg.value.getConversionRate() >= MINIMUM_USD, "Minimum contribution is $5");
		funders.push(msg.sender);
		addressToAmountFunded[msg.sender] += msg.value;
	} 

	function withdraw() public onlyOwner {

		(bool success,) = payable(i_owner).call{value: address(this).balance}("");
		if (!success) revert FundMe__CallFailed();

		for(uint funderIndex = 0; funderIndex < funders.length; funderIndex++) {
			address funder = funders[funderIndex];
			addressToAmountFunded[funder] = 0;
		}

		funders = new address[](0);
	}

	receive() external payable { fund(); }
	fallback() external payable { fund(); }

	modifier onlyOwner() {
		if(msg.sender != i_owner) revert FundMe__NotOwner();
		_;
	}
}



