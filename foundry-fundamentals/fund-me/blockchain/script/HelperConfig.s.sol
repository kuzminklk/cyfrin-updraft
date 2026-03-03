

// SPDX-License-Identifier: MIT

// Set appropriate Chainlink price-feed contract address depending of chain


pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";
import { MockV3Aggregator } from "../test/mocks/MockV3Aggregator.sol";


contract HelperConfig is Script {

	uint8 public constant DECIMALS = 8;
	int256 public constant INITIAL_PRICE = 3000e8;

	struct Config {
		address priceFeed;
	}

	Config public activeConfig;

	constructor() {
		if (block.chainid == 11155111) {
			activeConfig = getSepoliaConfig();
		} else if (block.chainid == 1) {
			activeConfig = getMainnetConfig();
		} else {
			activeConfig = getAnvilConfig();
		}
	}

	function getSepoliaConfig() public pure returns (Config memory) {
		Config memory config = Config({
			priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
		});
		return config;
	}

	function getMainnetConfig() public pure returns (Config memory) {
		Config memory config = Config({
			priceFeed: 	0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
		});
		return config;
	}

	function getAnvilConfig() public returns (Config memory)  {

		// If mock already created
		if (activeConfig.priceFeed != address(0)) {
			return activeConfig;
		}

		vm.startBroadcast();
			MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
		vm.stopBroadcast();

		Config memory config = Config({
			priceFeed: 	address(mockPriceFeed)
		});

		return config;
	}
}