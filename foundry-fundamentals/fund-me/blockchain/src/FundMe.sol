

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { PriceConverter } from "./PriceConverter.sol";


error FundMe__NotOwner();
error FundMe__CallFailed();

contract FundMe {

	using PriceConverter for uint256;

	uint256 public constant MINIMUM_USD = 5e18;

	address public immutable OWNER;
	address public immutable PRICE_FEED_ADDRESS; 

	address[] public sFunders;
	mapping(address funder => uint256 amountFunded) public sAddressToAmountFunded;

	constructor(address priceFeedAddress) {
		OWNER = msg.sender;
		PRICE_FEED_ADDRESS = priceFeedAddress;
	}

	function fund() public payable {
		require(msg.value.getConversionRate(PRICE_FEED_ADDRESS) >= MINIMUM_USD, "Minimum contribution is $5");
		sFunders.push(msg.sender);
		sAddressToAmountFunded[msg.sender] += msg.value;
	} 

	function withdraw() public onlyOwner {

		(bool success,) = payable(OWNER).call{value: address(this).balance}("");
		if (!success) revert FundMe__CallFailed();

		uint256 fundersLength = sFunders.length;

		for(uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
				address funder = sFunders[funderIndex];
				sAddressToAmountFunded[funder] = 0;
		}

		sFunders = new address[](0);
	}

	receive() external payable { fund(); }
	fallback() external payable { fund(); }

	modifier onlyOwner() {
		if(msg.sender != OWNER) revert FundMe__NotOwner();
		_;
	}
}



