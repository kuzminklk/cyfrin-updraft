

// SPDX-License-Identifier: MIT  

pragma solidity ^0.8.26;

import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


contract Airdrop {
	using SafeERC20 for IERC20;

	error Airdrop__InvalidProof();
	error Airdrop__AccountAlreadyHasClaimed();

	bytes32 public immutable i_merkleRoot;
	IERC20 public immutable i_token;
	address[] private s_claimers;
	mapping(address claimer => bool claimed) private s_hasClaimed;

	event Claimed(address account, uint256 amount);

	constructor(bytes32 _merkleRoot, IERC20 _token) {
		i_merkleRoot = _merkleRoot;
		i_token = _token;
	}

	function claim(address _account, uint256 _amount, bytes32[] calldata _merkleProof) external {
		// Check if account already has claimed
		if (s_hasClaimed[_account]) {
			revert Airdrop__AccountAlreadyHasClaimed();
		}

		// Hash _account and _amount to produce leaf node of Merkle Tree
		// Hash twice to avoid collisions (second preimage attack)
		bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account, _amount))));
		bool verified = MerkleProof.verify(_merkleProof, i_merkleRoot, leaf);
		if (!verified) {
			revert Airdrop__InvalidProof();
		}

		s_hasClaimed[_account] = true;

		emit Claimed(_account, _amount);

		i_token.safeTransfer(_account, _amount);
	}
}