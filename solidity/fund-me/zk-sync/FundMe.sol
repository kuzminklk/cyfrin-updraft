

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


error FundMe__PriceStale();

library PriceConverter {

	function getConversionRate(uint amount) internal view returns(uint256) {
		return amount * getPrice() / 1e18;
	}

	function getPrice() internal view returns(uint) {

		address PRICE_FEED_ADDRESS = 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF;
		AggregatorV3Interface priceFeed = AggregatorV3Interface(PRICE_FEED_ADDRESS);

		(, int price ,, uint updatedAt,) = priceFeed.latestRoundData();

		// Check for staleness (Example: 1 hour heartbeat)
		if (block.timestamp - updatedAt > 3600) revert FundMe__PriceStale();

		return uint(price * 1e10);
	}

}


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



