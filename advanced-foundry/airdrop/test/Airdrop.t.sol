

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import { console, Test } from "forge-std/Test.sol";

import { Token } from "../src/Token.sol";
import { Airdrop } from "../src/Airdrop.sol";
import { Deploy } from "../script/Deploy.s.sol";


contract TestAirdrop is Test {

	address public USER_1;
	uint256 public USER_1_PRIVATE_KEY;
	address public USER_2;
	uint256 public USER_2_PRIVATE_KEY;
	address public USER_3;
	uint256 public USER_3_PRIVATE_KEY;

	bytes32[] public PROOF_FOR_USER_1 = [bytes32(0x88287c1d2c79b71eb062217bdacac40c679f0538a0fc2423df079a42a9c5c570)];

	uint256 public constant ALLOWED_AMOUNT_TO_CLAIM = 100e18; // 100 tokens with 1e18 percision
	uint256 public constant UNALLOWED_AMOUNT_TO_CLAIM = 50e18; // 50 tokens with 1e18 precision

	Token public token;
	Airdrop public airdrop;

	Deploy public deployer;


	function setUp() public {
		// USER_1 is in allowlist with 100e18 amount
		(USER_1, USER_1_PRIVATE_KEY) = makeAddrAndKey("USER_1"); 
		console.log("Created USER_1 with address: ", USER_1);

		// USER_2 is in allowlist with 100e18 amount
		(USER_2, USER_2_PRIVATE_KEY) = makeAddrAndKey("USER_2"); 
		console.log("Created USER_2 with address: ", USER_2);

		// USER_3 isn't in allowlist
		(USER_3, USER_3_PRIVATE_KEY) = makeAddrAndKey("USER_3");
		console.log("Created USER_3 with address: ", USER_3);

		deployer = new Deploy();
		(token, airdrop) = deployer.deploy();
	}

	function testAllowedUserCanClaim() public {
		uint256 startingBalance = token.balanceOf(USER_1);

		// Make a sign
		bytes32 digest = airdrop.getMessageHash(USER_1, ALLOWED_AMOUNT_TO_CLAIM);
		(uint8 v, bytes32 r, bytes32 s) = vm.sign(USER_1_PRIVATE_KEY, digest);
		
		vm.startPrank(USER_1);
			airdrop.claim(USER_1, ALLOWED_AMOUNT_TO_CLAIM, PROOF_FOR_USER_1, v, r, s);
		vm.stopPrank();

		uint256 endingBalance = token.balanceOf(USER_1);
		console.log("Ending balance for testAllowedUserCanClaim() is: ", endingBalance);

		assertEq(endingBalance - startingBalance, ALLOWED_AMOUNT_TO_CLAIM);
	}

	function testUnallowedUserCantClaim() public {
		uint256 startingBalance = token.balanceOf(USER_3);
		
		// Make a sign
		bytes32 digest = airdrop.getMessageHash(USER_3, ALLOWED_AMOUNT_TO_CLAIM);
		(uint8 v, bytes32 r, bytes32 s) = vm.sign(USER_3_PRIVATE_KEY, digest);
		
		vm.startPrank(USER_3);
			vm.expectRevert(Airdrop.Airdrop__InvalidProof.selector);
			airdrop.claim(USER_3, ALLOWED_AMOUNT_TO_CLAIM, PROOF_FOR_USER_1, v, r, s);
		vm.stopPrank();
	}

	function testAllowedUserCantClaimUnallowedAmount() public {
		uint256 startingBalance = token.balanceOf(USER_1);

		// Make a sign
		bytes32 digest = airdrop.getMessageHash(USER_1, UNALLOWED_AMOUNT_TO_CLAIM);
		(uint8 v, bytes32 r, bytes32 s) = vm.sign(USER_1_PRIVATE_KEY, digest);
		
		vm.startPrank(USER_1);
			vm.expectRevert(Airdrop.Airdrop__InvalidProof.selector);
			airdrop.claim(USER_1, UNALLOWED_AMOUNT_TO_CLAIM, PROOF_FOR_USER_1, v, r, s);
		vm.stopPrank();
	}

	function testAllowedUserCantClaimTwice() public {
		uint256 startingBalance = token.balanceOf(USER_1);

		// Make a sign
		bytes32 digest = airdrop.getMessageHash(USER_1, ALLOWED_AMOUNT_TO_CLAIM);
		(uint8 v, bytes32 r, bytes32 s) = vm.sign(USER_1_PRIVATE_KEY, digest);
		
		vm.startPrank(USER_1);
			airdrop.claim(USER_1, ALLOWED_AMOUNT_TO_CLAIM, PROOF_FOR_USER_1, v, r, s);
		vm.stopPrank();

		uint256 endingBalance = token.balanceOf(USER_1);
		console.log("Ending balance for testAllowedUserCanClaim() is: ", endingBalance);

		assertEq(endingBalance - startingBalance, ALLOWED_AMOUNT_TO_CLAIM);

		vm.startPrank(USER_1);
			vm.expectRevert(Airdrop.Airdrop__AccountAlreadyHasClaimed.selector);
			airdrop.claim(USER_1, ALLOWED_AMOUNT_TO_CLAIM, PROOF_FOR_USER_1, v, r, s);
		vm.stopPrank();
	}

	function testUnallowedUserCanClaimForAllowedUserWithSignature() public {
		uint256 startingBalance = token.balanceOf(USER_1);

		// Make a sign
		bytes32 digest = airdrop.getMessageHash(USER_1, ALLOWED_AMOUNT_TO_CLAIM);
		(uint8 v, bytes32 r, bytes32 s) = vm.sign(USER_1_PRIVATE_KEY, digest);
		
		vm.startPrank(USER_3);
			airdrop.claim(USER_1, ALLOWED_AMOUNT_TO_CLAIM, PROOF_FOR_USER_1, v, r, s);
		vm.stopPrank();

		uint256 endingBalance = token.balanceOf(USER_1);
		console.log("Ending balance for testAllowedUserCanClaim() is: ", endingBalance);

		assertEq(endingBalance - startingBalance, ALLOWED_AMOUNT_TO_CLAIM);
	}

	function testUnallowedUserCantClaimForAllowedUserWithoutSignature() public {
		uint256 startingBalance = token.balanceOf(USER_1);

		// Make a sign
		bytes32 digest = airdrop.getMessageHash(USER_1, ALLOWED_AMOUNT_TO_CLAIM);
		(uint8 v, bytes32 r, bytes32 s) = vm.sign(USER_3_PRIVATE_KEY, digest);
		
		vm.startPrank(USER_3);
			vm.expectRevert(Airdrop.Airdrop__InvalidSignature.selector);
			airdrop.claim(USER_1, ALLOWED_AMOUNT_TO_CLAIM, PROOF_FOR_USER_1, v, r, s);
		vm.stopPrank();
	}
}
