


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;


// — Libraries imports —

import { console, Test } from "forge-std/Test.sol";

// OpenZeppelin imports
import { ERC20Mock } from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

// Foundry-era-contracts imports
import { BOOTLOADER_FORMAL_ADDRESS } from "foundry-era-contracts/src/system-contracts/contracts/Constants.sol";
import { ACCOUNT_VALIDATION_SUCCESS_MAGIC } from "foundry-era-contracts/src/system-contracts/contracts/interfaces/IAccount.sol";
import { Transaction, MemoryTransactionHelper } from "foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";


// — Local imports —

import { Account as AccountAbstraction } from "../src/Account.sol"; // Use alias because Account is an struct from forge-std/Script.sol …



/**
 * @notice Tests for account abstraction
 */
contract AccountTest is Test {

	using MessageHashUtils for bytes32;

	uint256 constant TOKENS_AMOUNT_TO_MINT = 100e18; // 100 units with 18 decimal percision
	uint256 constant ETHER_AMOUNT = 100e18;
	bytes32 constant EMPTY_BYTES_32 = bytes32(0);

	address owner;
	uint256 ownerPrivateKey;
	address user1;
	address user2;

	AccountAbstraction public accountAbstractionContract;
	ERC20Mock public usdc;


	// − Functions —

	function setUp() public {
		user1 = makeAddr("user1");
		user2 = makeAddr("user2");
		(owner, ownerPrivateKey) = makeAddrAndKey("owner");
		console.log("Create owner at address: ", owner);
		console.log("With private key: ", ownerPrivateKey);

		vm.startPrank(owner);
			accountAbstractionContract = new AccountAbstraction();
			usdc = new ERC20Mock();
		vm.stopPrank();

		vm.deal(address(accountAbstractionContract), ETHER_AMOUNT);
	}


	/** 
	 * @notice Test that owner can directly execute commands from an «Account»
	 */
	function testOwnerCanExecuteCommands() public {
		// 1. Encode function call
		address destination = address(usdc);
		uint256 etherValue = 0;
		bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(accountAbstractionContract), TOKENS_AMOUNT_TO_MINT);

		// 2. Create transaction struct
		Transaction memory transaction = _createUnsignedTransaction(accountAbstractionContract.owner(), 113, destination, etherValue, functionData);

		// 3. Do call from an owner to mint mock tokens
		vm.startPrank(accountAbstractionContract.owner());
			accountAbstractionContract.executeTransaction(EMPTY_BYTES_32, EMPTY_BYTES_32, transaction);
		vm.stopPrank();

		// 4. Assert tokens amounts
		assertEq(TOKENS_AMOUNT_TO_MINT, usdc.balanceOf(address(accountAbstractionContract)));
	}


	function testValidateTransaction() public {
		// This snippet copied from the test above
		// —
			// 1. Encode function call
			address destination = address(usdc);
			uint256 etherValue = 0;
			bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(accountAbstractionContract), TOKENS_AMOUNT_TO_MINT);

			// 2. Create transaction struct
			Transaction memory transaction = _createUnsignedTransaction(accountAbstractionContract.owner(), 113, destination, etherValue, functionData);
		// —

		// 3. Sign the transaction
		transaction = _signTransaction(transaction, owner, ownerPrivateKey);

		// 4. Prank bootloader and validate transaction
		vm.startPrank(BOOTLOADER_FORMAL_ADDRESS);
			bytes4 magic = accountAbstractionContract.validateTransaction(EMPTY_BYTES_32, EMPTY_BYTES_32, transaction);
		vm.stopPrank();

		// Assert result of validation (“magic value”)
		assertEq(magic, ACCOUNT_VALIDATION_SUCCESS_MAGIC);
	}


	/** 
	 * @notice Create sign and populate Transaction struct with it
	 */
	function _signTransaction(Transaction memory _transaction, address _account, uint256 _accountPrivateKey) internal returns (Transaction memory) {
		// 1. Get the hash
		bytes32 usnignedTransactionHash = MemoryTransactionHelper.encodeHash(_transaction);

		// 2. Create the sign
		(uint8 v, bytes32 r, bytes32 s) = vm.sign(_accountPrivateKey, usnignedTransactionHash); // Note: v, r, s order here

		// 3. Populate transaction struct with sign
		Transaction memory signedTransaction = _transaction;
		signedTransaction.signature = abi.encodePacked(r, s, v); // Note: r, s, v order here

		return signedTransaction;
	}


	/** 
	 * @notice Create Transaction struct
	 */
	function _createUnsignedTransaction(address _from, uint8 _transactionType, address _to, uint256 _value, bytes memory _data) internal view returns (Transaction memory) {
		uint256 gasLimit = 16777216;
		uint256 nonce = vm.getNonce(address(accountAbstractionContract));
		bytes32[] memory factoryDependencies = new bytes32[](0);

		return Transaction({
			txType: _transactionType,
			from: uint256(uint160(_from)),
			to: uint256(uint160(_to)),
			gasLimit: gasLimit,
			gasPerPubdataByteLimit: gasLimit,
			maxFeePerGas: gasLimit,
			maxPriorityFeePerGas: gasLimit,
			paymaster: 0,
			nonce: nonce,
			value: _value,
			reserved: [uint256(0), uint256(0), uint256(0), uint256(0)],
			data: _data,
			signature: hex"",
			factoryDeps: factoryDependencies,
			paymasterInput: hex"",
			reservedDynamic: hex""
		});
	}

}
