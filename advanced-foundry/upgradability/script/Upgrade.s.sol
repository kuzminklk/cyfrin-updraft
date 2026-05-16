

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import { Script } from "forge-std/Script.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { DevOpsTools } from "foundry-devops/src/DevOpsTools.sol";

import { ValueMultiplication } from "../src/ValueMultiplication.sol";
import { Value } from "../src/Value.sol";


/**
 * @notice Upgrade contract to newer version
 */
contract Upgrade is Script {
	address public mostRecentlyDeployedProxy;
	ValueMultiplication public upgradedValueContract;
	Value public valueContractViaProxy;

	function run() public returns (Value) {
		mostRecentlyDeployedProxy = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);
		
		return upgrade(mostRecentlyDeployedProxy);
	}

	function upgrade(address _mostRecentlyDeployedProxy) public returns (Value) {
		vm.startBroadcast();
			upgradedValueContract = new ValueMultiplication();
			valueContractViaProxy = Value(_mostRecentlyDeployedProxy); // As proxy points to Value contract, we can cast it to «Value»
			valueContractViaProxy.upgradeToAndCall(address(upgradedValueContract), ""); // Can be upgraded as it inherit «UUPSUpgradeable»
		vm.stopBroadcast();

		return valueContractViaProxy;
	}
}