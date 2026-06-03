

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import { Script } from "forge-std/Script.sol";
import { PackedUserOperation } from "account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import { IEntryPoint } from "account-abstraction/contracts/interfaces/IEntryPoint.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import { Configuration } from "./Configuration.s.sol";


/**
 * @notice Generate, sign User Operation struct (used to send user actions from account abstraction to the appropriate pool)
 */
contract GenerateUserOperation is Script {

	using MessageHashUtils for bytes32;

	function run() public {

	}

	/**
	 * @notice Add sign to «PackedUserOperation» struct
	 */
	function generateAndSignUserOperation(bytes memory _callData, address _sender, uint256 _ownerPrivateKey, Configuration.NetworkConfiguration memory _networkConfiguration) public view returns (PackedUserOperation memory) {
		// 1. Generate User Operation struct
		uint256 nonce = vm.getNonce(_sender) - 1; // Add “- 1” to avoid “AA25 invalid account nonce” error
		PackedUserOperation memory userOperation =_generateUnsignedUserOperation(_callData, _sender, nonce);

		// 2. Get hash for User Operation struct
		bytes32 userOperationHash = IEntryPoint(_networkConfiguration.entryPoint).getUserOpHash(userOperation);

		// 3. Format Hash to ERC-191 digest
		bytes32 digest = userOperationHash.toEthSignedMessageHash();

		// 4. Generate sign form digest and add it to the User Operation struct. Then return it
		(uint8 v, bytes32 r, bytes32 s) = vm.sign(_ownerPrivateKey, digest); // Note: v, r, s order here
		userOperation.signature = abi.encodePacked(r, s, v); // Note: r, s, v order here
		return userOperation;
	}

	/**
	 * @notice Generate «PackedUserOperation» struct without sign
	 */
	function _generateUnsignedUserOperation(bytes memory _callData, address _sender, uint256 _nonce) public pure returns (PackedUserOperation memory) {
		uint128 verificationGasLimit = 16777216;
		uint128 maxPriorityFeePerGas = 256;
		uint128 callGasLimit = verificationGasLimit;
		uint128 maxFeePerGas = verificationGasLimit;

		return PackedUserOperation({
			sender: _sender,
			nonce: _nonce,
			initCode: hex"",
			callData: _callData,
			accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
			preVerificationGas: verificationGasLimit,
			gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
			paymasterAndData: hex"",
			signature: hex""
		});
	}
}