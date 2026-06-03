


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;


// — External imports —

import { console, Test } from "forge-std/Test.sol";

// Account Abstraction imports
import { PackedUserOperation } from "account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import { IEntryPoint } from "account-abstraction/contracts/interfaces/IEntryPoint.sol";
import { SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS } from "account-abstraction/contracts/core/Helpers.sol";

// OpenZeppelin imports
import { ERC20Mock } from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";


// — Local imports —

import { Account as AccountAbstraction } from "../src/Account.sol"; // Use alias because Account is an struct from forge-std/Script.sol …
import { Configuration } from "../script/Configuration.s.sol";
import { Deploy } from "../script/Deploy.s.sol";
import { GenerateUserOperation } from "../script/GenerateUserOperation.s.sol";



/**
 * @notice Tests for account abstraction
 */
contract AccountTest is Test {

	using MessageHashUtils for bytes32;

	uint256 constant TOKENS_AMOUNT_TO_MINT = 100e18; // 100 units with 18 decimal percision
	uint256 constant ETHER_AMOUNT = 100e18;

	address owner;
	uint256 ownerPrivateKey;
	address user1;
	address user2;

	Deploy public deployer;
	Configuration public configuration;
	GenerateUserOperation public userOperationGenerator;
	AccountAbstraction public accountAbstractionContract;
	ERC20Mock public usdc;

	function setUp() public {
		user1 = makeAddr("user1");
		user2 = makeAddr("user2");
		(owner, ownerPrivateKey) = makeAddrAndKey("owner");
		console.log("Create owner at address: ", owner);
		console.log("With private key: ", ownerPrivateKey);

		vm.startPrank(owner);
			// Here I don't use «Deploy» script as I can't prank owner for script (owner sets as «Deploy» contract)
			// —
			configuration = new Configuration();
			accountAbstractionContract = new AccountAbstraction(configuration.getNetworkConfiguration().entryPoint);
			// —

			usdc = new ERC20Mock();
			userOperationGenerator = new GenerateUserOperation();
		vm.stopPrank();

		vm.deal(address(accountAbstractionContract), ETHER_AMOUNT);
	}

	/** 
	 * @notice Test that owner can directly execute commands from «Account»
	 */
	function testOwnerCanExecuteCommands() public {
		// 1. Encode function call
		address destination = address(usdc);
		uint256 etherValue = 0;
		bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(accountAbstractionContract), TOKENS_AMOUNT_TO_MINT);

		// 2. Do call from an owner to mint mock tokens
		vm.startPrank(accountAbstractionContract.owner());
			accountAbstractionContract.execute(destination, etherValue, functionData);
		vm.stopPrank();

		// 3. Assert tokens amounts
		assertEq(TOKENS_AMOUNT_TO_MINT, usdc.balanceOf(address(accountAbstractionContract)));
	}

	/** 
	 * @notice Test that not owner can't directly execute commands from «Account»
	 */
	function testNotOwnerCannotExecuteCommands() public {
		// 1. Encode function call
		address destination = address(usdc);
		uint256 etherValue = 0;
		bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(accountAbstractionContract), TOKENS_AMOUNT_TO_MINT);

		// 2. Do call from not an owner, expect revert
		vm.startPrank(user1);
			vm.expectRevert(AccountAbstraction.Account__NotFromEntryPointOrOwner.selector);
			accountAbstractionContract.execute(destination, etherValue, functionData);
		vm.stopPrank();
	}

	/** 
	 * @notice Test that signing user operation works correctly (can recover owner from sign)
	 * @dev Caller-agnostic test
	 */
	function testRecoverSignedUserOperation() public {
		// 1. Encode function call
		address destination = address(usdc);
		uint256 etherValue = 0;
		bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(accountAbstractionContract), TOKENS_AMOUNT_TO_MINT);

		// 2. Encode execution data (part of user operation)
		bytes memory executeCallData = abi.encodeWithSelector(AccountAbstraction.execute.selector, destination, etherValue, functionData);

		// 3. Generate and sign user operation
		PackedUserOperation memory userOperation = userOperationGenerator.generateAndSignUserOperation(executeCallData, address(accountAbstractionContract), ownerPrivateKey, configuration.getNetworkConfiguration());

		// 4. Get hash of user operation
		bytes32 userOperationHash = IEntryPoint(configuration.getNetworkConfiguration().entryPoint).getUserOpHash(userOperation);

		// 5. Recover signtature from the hash of user operation
		address signer = ECDSA.recover(userOperationHash.toEthSignedMessageHash(), userOperation.signature);

		// 6. Assert signer and owner of accoutn abstraction
		assertEq(signer, accountAbstractionContract.owner());
	}

	/** 
	 * @notice Test validation of user operation from “EntryPoint“ contract
	 */
	function testValidateUserOperation() public {
		// This snippet copied from the test above
		// —
			// 1. Encode function call
			address destination = address(usdc);
			uint256 etherValue = 0;
			bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(accountAbstractionContract), TOKENS_AMOUNT_TO_MINT);

			// 2. Encode execution data (part of user operation)
			bytes memory executeCallData = abi.encodeWithSelector(AccountAbstraction.execute.selector, destination, etherValue, functionData);

			// 3. Generate and sign user operation
			PackedUserOperation memory userOperation = userOperationGenerator.generateAndSignUserOperation(executeCallData, address(accountAbstractionContract), ownerPrivateKey, configuration.getNetworkConfiguration());

			// 4. Get hash of user operation
			bytes32 userOperationHash = IEntryPoint(configuration.getNetworkConfiguration().entryPoint).getUserOpHash(userOperation);
		// —

		// 5. Validate user operation
		vm.startPrank(configuration.getNetworkConfiguration().entryPoint);
			uint256 missingAccountFunds = 1e18; // 1 unit with 18 decimals of percision
			uint256 validationData = accountAbstractionContract.validateUserOp(userOperation, userOperationHash, missingAccountFunds);
		vm.stopPrank();

		// 6. Assert that validation passed
		assertEq(validationData, SIG_VALIDATION_SUCCESS);
	}

	/** 
	 * @notice Test that “EntryPoint“ contract can execute commands from user operation
	 */
	function testEntryPointCanExecuteCommands() public {
		// This snippet copied from the test two times above
		// —
			// 1. Encode function call
			address destination = address(usdc);
			uint256 etherValue = 0;
			bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(accountAbstractionContract), TOKENS_AMOUNT_TO_MINT);

			// 2. Encode execution data (part of user operation)
			bytes memory executeCallData = abi.encodeWithSelector(AccountAbstraction.execute.selector, destination, etherValue, functionData);

			// 3. Generate and sign user operation
			PackedUserOperation memory userOperation = userOperationGenerator.generateAndSignUserOperation(executeCallData, address(accountAbstractionContract), ownerPrivateKey, configuration.getNetworkConfiguration());
		// —

		// 4. Create array of user operations and populate it
		PackedUserOperation[] memory userOperations = new PackedUserOperation[](1);
		userOperations[0] = userOperation;

		// 5. Submit user operation to “Entry Point” (can be done from any account)
		vm.startPrank(user1, user1); // Set both “msg.sender” and “tx.origin”
			IEntryPoint(configuration.getNetworkConfiguration().entryPoint).handleOps(userOperations, payable(address(user1)));
		vm.stopPrank();

		// 6. Assert that command got executed
		assertEq(TOKENS_AMOUNT_TO_MINT, usdc.balanceOf(address(accountAbstractionContract)));
	}
}
