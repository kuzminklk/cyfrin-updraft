

// SPDX-License-Identifier: MIT  

pragma solidity ^0.8.26;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";


/**
 * @author kuzminklk
 * @notice Upgradable contract implementation
 * @notice “Second” version
 * @dev Uses UUPS
 */
contract ValueMultiplication is UUPSUpgradeable, Initializable, OwnableUpgradeable {
	uint256 public s_value;
	uint256 public version = 2;

	// Use initialize() in proxy instead of constructor(). Because constructor() sets storage to implementation, not the proxy
	function initialize() public initializer {
		__Ownable_init(msg.sender);
	}
	
	function setValue(uint256 _value) public {
		s_value = _value * 2;
	}

	function _authorizeUpgrade(address newImplementation) internal override onlyOwner() {}
}