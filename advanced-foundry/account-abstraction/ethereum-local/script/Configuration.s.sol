

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import { Script, console } from "forge-std/Script.sol";
import { EntryPoint } from "account-abstraction/contracts/core/EntryPoint.sol";


/**
 * @notice Configure «EntryPoint» contract for appropriate chain
 */
contract Configuration is Script {
	error Configuration__InvalidChainId();

	struct NetworkConfiguration {
		address entryPoint;
	}

	uint256 constant ANVIL_CHAIN_ID = 31337;
	uint256 constant ETHEREUM_SEPOLIA_CHAIN_ID = 11155111;
	uint256 constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;

	NetworkConfiguration public anvilNetworkConfiguration;
	mapping(uint256 chainId => NetworkConfiguration network) public networkConfigs;

	/**
	 * @notice Sets all the configurations for appropriate chains to mapping
	 */
	constructor() {
		networkConfigs[ETHEREUM_SEPOLIA_CHAIN_ID] = getEthereumSepoliaConfiguration();
		networkConfigs[ZKSYNC_SEPOLIA_CHAIN_ID] = getZksyncSepoliaConfiguration();
	}

	/**
	 * @notice Wrapper to get configuration by «block.chainid»
	 */
	function getNetworkConfiguration() public returns (NetworkConfiguration memory) {
		return getNetworkConfigurationByChainId(block.chainid);
	}

	/**
	 * @notice Get configuration for appropriate chain by chain ID
	 */
	function getNetworkConfigurationByChainId(uint256 _chainId) public returns (NetworkConfiguration memory) {
		if (_chainId == ANVIL_CHAIN_ID) {
			return getOrCreateAnvilConfiguration();
		} else if (networkConfigs[_chainId].entryPoint != address(0)) {
			return networkConfigs[_chainId];
		} else {
			revert Configuration__InvalidChainId();
		}
	}

	/**
	 * @notice Get configuration for Anvil or create it (deploy mocks, …)
	 */
	function getOrCreateAnvilConfiguration() public returns (NetworkConfiguration memory) {
		if (anvilNetworkConfiguration.entryPoint != address(0)) {
			return anvilNetworkConfiguration;
		}

		// Deploy mock
		EntryPoint entryPointContract = new EntryPoint();
		console.log(unicode"Deployed «EntryPoint» contract for Anvil at:", address(entryPointContract));

		anvilNetworkConfiguration = NetworkConfiguration({ entryPoint: address(entryPointContract) });

		return anvilNetworkConfiguration;
	}

	function getEthereumSepoliaConfiguration() public pure returns (NetworkConfiguration memory) {
		return NetworkConfiguration({ entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789 });
	}

	function getZksyncSepoliaConfiguration() public pure returns (NetworkConfiguration memory) {
		return NetworkConfiguration({ entryPoint: address(0) });
	}

}