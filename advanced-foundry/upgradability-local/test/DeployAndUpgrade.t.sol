

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import { console, Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { Deploy } from "../script/Deploy.s.sol";
import { Upgrade } from "../script/Upgrade.s.sol";
import { Value } from "../src/Value.sol";


contract DeployAndUpgrade is Test {
	// Contracts
	Deploy public deployer;
	Upgrade public upgrader;
	Value public valueContractViaProxy;
	ERC1967Proxy public proxyContract;

	// Users and balances
	address public OWNER = makeAddr("OWNER");
	uint256 public OWNER_INITIAL_BALANCE = 100 ether;

	function setUp() public {
		vm.deal(OWNER, OWNER_INITIAL_BALANCE);
		deployer = new Deploy();
		upgrader = new Upgrade();
		( , proxyContract) = deployer.run();
		valueContractViaProxy = Value(address(proxyContract)); // As proxy points to Value contract, we can cast it to «Value»
	}

	function testUpgrade() public {
		valueContractViaProxy = upgrader.upgrade(address(valueContractViaProxy));
		assertEq(valueContractViaProxy.version(), 2);
	}
}
