

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


error FundMe__PriceStale();

library PriceConverter {

	function getConversionRate(uint amount) internal view returns(uint256) {
		return amount * getPrice() / 1e18;
	}

	function getPrice() internal view returns(uint) {

		address PRICE_FEED_ADDRESS = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
		AggregatorV3Interface priceFeed = AggregatorV3Interface(PRICE_FEED_ADDRESS);

		(, int price ,, uint updatedAt,) = priceFeed.latestRoundData();

		// Check for staleness (Example: 1 hour heartbeat)
		if (block.timestamp - updatedAt > 3600) revert FundMe__PriceStale();

		return uint(price * 1e10);
	}

}



