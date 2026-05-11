

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import { console, Test } from "forge-std/Test.sol";
import { PackedUserOperation } from "account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import { IEntryPoint } from "account-abstraction/contracts/interfaces/IEntryPoint.sol";
import { ERC20Mock } from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import { Account as AccountAbstraction } from "../src/ethereum/Account.sol"; // Use alias because Account is an struct from forge-std/Script.sol …
import { Configuration } from "../script/Configuration.s.sol";
import { Deploy } from "../script/Deploy.s.sol";
import { GenerateUserOperation } from "../script/GenerateUserOperation.s.sol";


/**
 * @notice Tests for account abstraction
 */
contract AccountTest is Test {

		using MessageHashUtils for bytes32;

	uint256 constant TOKENS_AMOUNT_TO_MINT = 100e18; // 100 units with 18 decimal percision

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
			// Here I use code snippet form «Deploy.s.sol» as I can't prank owner for script (owner sets as «Deploy» contract)
			// —
			Configuration configuration = new Configuration();
			Configuration.NetworkConfiguration memory networkConfiguration = configuration.getNetworkConfiguration();

			AccountAbstraction accountAbstractionContract = new AccountAbstraction(networkConfiguration.entryPoint);
			// —

			usdc = new ERC20Mock();
			userOperationGenerator = new GenerateUserOperation();
		vm.stopPrank();
	}

	/** 
	 * @notice Test that owner can directly execute commands from «Account»
	 */
	function testOwnerCanExecuteCommands() public {
		address destination = address(usdc);
		uint256 etherValue = 0;
		bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(accountAbstractionContract), TOKENS_AMOUNT_TO_MINT);
		vm.startPrank(accountAbstractionContract.owner());
			accountAbstractionContract.execute(destination, etherValue, functionData);
		vm.stopPrank();

		assertEq(TOKENS_AMOUNT_TO_MINT, usdc.balanceOf(address(accountAbstractionContract)));
	}

	/** 
	 * @notice Test that not owner can't directly execute commands from «Account»
	 */
	function testNotOwnerCannotExecuteCommands() public {
		address destination = address(usdc);
		uint256 etherValue = 0;
		bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(accountAbstractionContract), TOKENS_AMOUNT_TO_MINT);

		vm.startPrank(user1);
			vm.expectRevert(AccountAbstraction.Account__NotFromEntryPointOrOwner.selector);
			accountAbstractionContract.execute(destination, etherValue, functionData);
		vm.stopPrank();
	}

	/** 
	 * @notice Test that …
	 */
	function testRecoverSignedOperation() public {
		// 1. Encode function call
		address destination = address(usdc);
		uint256 etherValue = 0;
		bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(accountAbstractionContract), TOKENS_AMOUNT_TO_MINT);

		// 2. Encode execution data (part of user operation)
		bytes memory executeCallData = abi.encodeWithSelector(AccountAbstraction.execute.selector, destination, etherValue, functionData);

		// 3. Generate and sign user operation
		PackedUserOperation memory userOperation = userOperationGenerator.generateAndSignUserOperation(executeCallData, owner, ownerPrivateKey, configuration.getNetworkConfiguration());

		// 4. Get hash of user operation
		bytes32 userOperationHash = IEntryPoint(configuration.getNetworkConfiguration().entryPoint).getUserOpHash(userOperation);

		// 5. Recover signtature from the hash of user operation
		address signer = ECDSA.recover(userOperationHash.toEthSignedMessageHash(), userOperation.signature);

		// 6. Assert signer and owner of accoutn abstraction
		assertEq(signer, accountAbstractionContract.owner());
	}
}
