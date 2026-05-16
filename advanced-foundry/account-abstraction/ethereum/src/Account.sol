


// SPDX-License-Identifier: MIT  

pragma solidity ^0.8.28;


// — External imports —

// Account Abstraction imports
import { IAccount } from "account-abstraction/contracts/interfaces/IAccount.sol";
import { IEntryPoint } from "account-abstraction/contracts/interfaces/IEntryPoint.sol";
import { PackedUserOperation } from "account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import { SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS } from "account-abstraction/contracts/core/Helpers.sol";

// OpenZeppelin imports
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";



/**
 * @author kuzminklk
 * @notice Account abstraction smart-contract for Ethereum
 * @dev Uses ERC-4337
 * @dev Sends actions to appropriate pool, then to «EntryPoint› contract
 * @dev Access to account only for the owner (access mechanics) by the sign
 */
contract Account is IAccount, Ownable {

	error Account__NotFromEntryPoint();
	error Account__NotFromEntryPointOrOwner();
	error Account__CallFailed(bytes result);

	IEntryPoint public immutable i_entryPoint;


	// ——— Modifiers ———

	modifier onlyEntryPoint() {
		if (msg.sender != address(i_entryPoint)) {
			revert Account__NotFromEntryPoint();
		}
		_;
	}

	modifier onlyEntryPointOrOwner() {
		if (msg.sender != address(i_entryPoint) && msg.sender != owner()) {
			revert Account__NotFromEntryPointOrOwner();
		}
		_;
	}


	// ——— Functions ———

	constructor(address _entryPoint) Ownable(msg.sender) {
		i_entryPoint = IEntryPoint(_entryPoint);
	}


	// — External Functions —

	receive() external payable {}

	function execute(address _destination, uint256 _value, bytes calldata _functionData) external onlyEntryPointOrOwner {
		(bool success, bytes memory result) = _destination.call{value: _value}(_functionData);
		if (!success) {
			revert Account__CallFailed(result);
		}
	}

	/**
	 * @notice Validate user operation
	 * @dev General validation function from an interface
	 * @dev Do not do nonce validation as it handled by entry point smart-contract
	 * @dev Can put any validation logic (session keys, multisign, etc.)
	 */
	function validateUserOp(PackedUserOperation calldata _userOperation, bytes32 _userOperationHash, uint256 _missingAccountFunds) external onlyEntryPoint returns (uint256 _validationData) {
		_validationData = _validateSignature(_userOperation, _userOperationHash);
		_payPrefund(_missingAccountFunds);
	}


	// — Internal Functions —

	/**
	 * @notice Validate signature to give or not access to operation
	 * @dev Implement simple logic: if signer is an owner, it's give access
	 * @dev Uses «Ownable», «ECDSA», «MessageHashUtils» smart-contracts from OpenZeppelin
	 */
	function _validateSignature(PackedUserOperation calldata _userOperation, bytes32 _userOperationHash) internal view returns (uint256 _validationData) {
		bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(_userOperationHash);
		address signer = ECDSA.recover(ethSignedMessageHash, _userOperation.signature);
		if (signer != owner()) {
			return SIG_VALIDATION_FAILED;
		}
		return SIG_VALIDATION_SUCCESS;
	}

	/**
	 * @notice Pay prefund for alt-pool validators, which sends transaction to entry point
	 */
	function _payPrefund(uint256 _missingAccountFunds) internal {
		if (_missingAccountFunds > 0) {
			(bool success, ) = payable(msg.sender).call{value: _missingAccountFunds, gas: type(uint256).max}("");
		}
	}
}