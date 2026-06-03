

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import { Script } from "forge-std/Script.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { Value } from "../src/Value.sol";


contract Deploy is Script {
	Value public valueContract;
	ERC1967Proxy public proxyContract;

	function run() public returns (Value, ERC1967Proxy) {
		vm.startBroadcast();
			valueContract = new Value();	
			proxyContract = new ERC1967Proxy(address(valueContract), abi.encodeCall(valueContract.initialize, ()));
		vm.stopBroadcast();

		return (valueContract, proxyContract);
	}
}