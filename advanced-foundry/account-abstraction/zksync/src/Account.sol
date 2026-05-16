


// SPDX-License-Identifier: MIT  

pragma solidity ^0.8.28;


// — External imports —

// OpenZeppelin imports
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

// Foundry-era-contracts imports
import { IAccount, ACCOUNT_VALIDATION_SUCCESS_MAGIC } from "foundry-era-contracts/src/system-contracts/contracts/interfaces/IAccount.sol";
import { INonceHolder } from "foundry-era-contracts/src/system-contracts/contracts/interfaces/INonceHolder.sol";
import { Transaction, MemoryTransactionHelper } from "foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";
import { SystemContractsCaller } from "foundry-era-contracts/src/system-contracts/contracts/libraries/SystemContractsCaller.sol";
import { Utils } from "foundry-era-contracts/src/system-contracts/contracts/libraries/Utils.sol";
import { NONCE_HOLDER_SYSTEM_CONTRACT, BOOTLOADER_FORMAL_ADDRESS, DEPLOYER_SYSTEM_CONTRACT } from "foundry-era-contracts/src/system-contracts/contracts/Constants.sol";



/**
 * @author kuzminklk
 * @notice Account contract for Zksync
 *
 * ——— Lifecycle of a type 113 (0x71) transaction ———
 * (Sender of the transaction is Bootloader system contract)
 *
 * — Phase 1. Validation —
 * 1. The user sends transaction to the “ZKsync API client” (aka “light node”)
 * 2. It (“ZKsync API client”) checks the nonce using system contract
 * 3. It calls “validateTransaction”, which update the nonce
 * 4. It checks that nonce was updated
 * 5. It calls “payForTransaction”, …
 * 6. It verifies that Bootloader gets paid
 * 
 * — Phase 2. Execution —
 * 1. “ZKsync API client” sends validated transaction to the main node (as of today, same as sequencer)
 * 2. Main node calls “executeTransaction” 
 * 3. Optionally, “postTransaction” is called
 */
contract Account is IAccount, Ownable {
	using MemoryTransactionHelper for Transaction;

	error Account__NotEnoughtBalance();
	error Account__NotFromBootloader();
	error Account__ExecutionFailed();
	error Account__NotFromBootloaderOrOwner();
	error Account__FailedToPayFee();
	error Account__InvalidSignature();

	modifier requireFromBootloader() {
		if (msg.sender != BOOTLOADER_FORMAL_ADDRESS) {
			revert Account__NotFromBootloader();
		}
		_;
	}

	modifier requireFromBootloaderOrOwner() {
		if (msg.sender != BOOTLOADER_FORMAL_ADDRESS && msg.sender != owner()) {
			revert Account__NotFromBootloaderOrOwner();
		}
		_;
	}

	constructor() Ownable(msg.sender) {}

	receive() external payable {}

	/**
	 * @notice Validate the transaction. Called by “light node”
	 * @dev Similar as “Validate user operation” for Ethereum account abstraction
	 * @dev Increase the nonce
	 * @dev Check account funds (this contract doesn't implement paymaster) 
	 * @dev External part of validation function
	 */
	function validateTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction memory _transaction) external payable requireFromBootloader returns (bytes4 magic) {
		return _validateTransaction(_transaction);
	}

	/**
	 * @dev Internal part of validation function
	 */
	function _validateTransaction(Transaction memory _transaction) internal returns (bytes4 magic) {
		// 1. Insrease the nonce by calling a system contract
		SystemContractsCaller.systemCallWithPropagatedRevert(uint32(gasleft()), address(NONCE_HOLDER_SYSTEM_CONTRACT), 0, abi.encodeCall(INonceHolder.incrementMinNonceIfEquals, _transaction.nonce));

		// 2. Check the fee to pay
		uint256 totalFee = _transaction.totalRequiredBalance();
		if (totalFee > address(this).balance) {
			revert Account__NotEnoughtBalance();
		}

		// 3. Check the signature
		bytes32 transactionHash = _transaction.encodeHash();
		address signer = ECDSA.recover(transactionHash, _transaction.signature);
		bool isValidSigner = signer == owner();

		// 4. Retrun magic number or revert
		if (isValidSigner) {
			magic = ACCOUNT_VALIDATION_SUCCESS_MAGIC;
		} else {
			magic = bytes4(0);
		}

		return magic;
	}

	/**
	 * @notice Execute the transaction. Called by “main node”
	 * @dev External part of execution function
	 */
	function executeTransaction(bytes32 /* _txHash */, bytes32 /* _suggestedSignedHash */, Transaction memory _transaction) external payable requireFromBootloaderOrOwner {
		_executeTransaction(_transaction);
	}

	/**
	 * @dev Internal part of execution function
	 */
	function _executeTransaction(Transaction memory _transaction) internal {
		address to = address(uint160(_transaction.to));
		uint128 value = Utils.safeCastToU128(_transaction.value);
		bytes memory data = _transaction.data;

		if (to == address(DEPLOYER_SYSTEM_CONTRACT)) {
			// Handle here call to the system contract
			uint32 gas = Utils.safeCastToU32(gasleft());
			SystemContractsCaller.systemCallWithPropagatedRevert(gas, to, value, data);
		} else {
			bool success;
			assembly {
				success := call(gas(), to, value, add(data, 0x20), mload(data), 0, 0)
			}

			if (!success) {
				revert Account__ExecutionFailed();
			}
		}
	}

	function executeTransactionFromOutside(Transaction memory _transaction) external payable {
		bytes4 magic = _validateTransaction(_transaction);
		if (magic != ACCOUNT_VALIDATION_SUCCESS_MAGIC) {
			revert Account__InvalidSignature();
		} else {
			_executeTransaction(_transaction);
		}
	}

	function payForTransaction(bytes32 /* _txHash */, bytes32 /* _suggestedSignedHash */, Transaction memory _transaction) external payable {
		bool success = _transaction.payToTheBootloader();
		if (!success) {
			revert Account__FailedToPayFee();
		}
	}

	/**
	 * @dev Don't realize paymaster
	 */
	function prepareForPaymaster(bytes32 _txHash, bytes32 _possibleSignedHash, Transaction memory _transaction) external payable {

	}
}