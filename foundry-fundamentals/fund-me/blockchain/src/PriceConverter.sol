

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


error FundMe__PriceStale();

library PriceConverter {

	function getConversionRate(uint256 amount, address priceFeedAddress) internal view returns (uint256) {
		return (amount * getPrice(priceFeedAddress)) / 1e18;
	}

	function getPrice(address priceFeedAddress) internal view returns (uint256) {
		AggregatorV3Interface priceFeed = AggregatorV3Interface(
			priceFeedAddress
		);

		(, int price, , uint256 updatedAt, ) = priceFeed.latestRoundData();

		// Check for staleness (Example: 1 hour heartbeat)
		if (block.timestamp - updatedAt > 3600) revert FundMe__PriceStale();

		return uint256(price * 1e10);
	}

	function getVersion(address priceFeedAddress) public view returns (uint256) {
		AggregatorV3Interface priceFeed = AggregatorV3Interface(
				priceFeedAddress
			);
		return priceFeed.version();
	}
}
