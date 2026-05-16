

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import { Script, console } from "forge-std/Script.sol";
import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { DevOpsTools } from "foundry-devops/src/DevOpsTools.sol";

import { Token } from "../src/Token.sol";
import { Airdrop } from "../src/Airdrop.sol";


/**
 * @notice Claim interacion
 */
contract Claim is Script {

	address public USER_1;
	uint256 public USER_1_PRIVATE_KEY;
	address public USER_2;
	uint256 public USER_2_PRIVATE_KEY;
	address public USER_3;
	uint256 public USER_3_PRIVATE_KEY;

	bytes32[] public PROOF_FOR_USER_1 = [bytes32(0x88287c1d2c79b71eb062217bdacac40c679f0538a0fc2423df079a42a9c5c570)];
	uint256 public constant ALLOWED_AMOUNT_TO_CLAIM = 100e18; // 100 tokens with 1e18 percision
	
	function claim(address airdrop) public {

		// USER_1 is in allowlist with 100e18 amount
		(USER_1, USER_1_PRIVATE_KEY) = makeAddrAndKey("USER_1"); 
		console.log("Created USER_1 with address: ", USER_1);

		// USER_2 is in allowlist with 100e18 amount
		(USER_2, USER_2_PRIVATE_KEY) = makeAddrAndKey("USER_2"); 
		console.log("Created USER_2 with address: ", USER_2);

		// USER_3 isn't in allowlist
		(USER_3, USER_3_PRIVATE_KEY) = makeAddrAndKey("USER_3");
		console.log("Created USER_3 with address: ", USER_3);

		// Make a sign
		bytes32 digest = Airdrop(airdrop).getMessageHash(USER_1, ALLOWED_AMOUNT_TO_CLAIM);
		(uint8 v, bytes32 r, bytes32 s) = vm.sign(USER_1_PRIVATE_KEY, digest);

		vm.startBroadcast(USER_3);
			Airdrop(airdrop).claim(USER_1, ALLOWED_AMOUNT_TO_CLAIM, PROOF_FOR_USER_1, v, r, s);
		vm.stopBroadcast();
	}

	function run() external {
		address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Airdrop", block.chainid);
		claim(mostRecentlyDeployed);
	}
}