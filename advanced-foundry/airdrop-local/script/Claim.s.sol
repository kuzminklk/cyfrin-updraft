

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import { Script, console } from "forge-std/Script.sol";
import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { Token } from "../src/Token.sol";
import { Airdrop } from "../src/Airdrop.sol";


/**
 * @notice Claim tokens interaction
 */
contract Claim is Script {
	uint256 public constant ALLOWED_AMOUNT_TO_CLAIM = 100e18; // 100 tokens with 1e18 percision
	
	function claim(address _airdropContract, bytes32[] calldata _proof) public {
		vm.startBroadcast();
			Airdrop(_airdropContract).claim(ALLOWED_AMOUNT_TO_CLAIM, _proof);
		vm.stopBroadcast();
	}

	function run(address _airdropContract, bytes32[] calldata _proof) external {
		claim(_airdropContract, _proof);
	}
}