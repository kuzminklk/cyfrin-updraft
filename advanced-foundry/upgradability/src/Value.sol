

// SPDX-License-Identifier: MIT  

pragma solidity ^0.8.26;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";


contract Value is UUPSUpgradeable, Initializable, OwnableUpgradeable {
	uint256 internal s_value;

	// Use initialize() in proxy instead of constructor(). Because constructor() sets storage to implementation, not the proxy
	function initialize() public initializer {
		__Ownable_init(msg.sender);
	}

	function getValue() public returns (uint256) {
		return s_value;
	}
	
	function setValue(uint256 _value) public {
		s_value = _value;
	}
	
	function version() public returns (uint256) {
		return 1;
	}

	function _authorizeUpgrade(address newImplementation) internal override onlyOwner() {}
}