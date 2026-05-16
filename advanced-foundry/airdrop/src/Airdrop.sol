

// SPDX-License-Identifier: MIT  

pragma solidity ^0.8.26;

import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";


/**
 * @author kuzminklk
 * @notice Airdrop sender
 * @dev Implements Merkle Trees for airdrop allowing
 * @dev Implements ECDSA signing and EIP712 standart for user ability to pay fees for another account
 */
contract Airdrop is EIP712 {
	using SafeERC20 for IERC20;

	error Airdrop__InvalidProof();
	error Airdrop__AccountAlreadyHasClaimed();
	error Airdrop__InvalidSignature();

	bytes32 private constant MESSAGE_TYPEHASH = keccak256("Claim(address account, uint256 amount)");

	bytes32 public immutable i_merkleRoot;
	IERC20 public immutable i_token;
	address[] private s_claimers;
	mapping(address claimer => bool claimed) private s_hasClaimed;

	struct Claim {
		address account;
		uint256 amount;
	}

	event Claimed(address account, uint256 amount);

	constructor(bytes32 _merkleRoot, IERC20 _token) EIP712("Airdrop", "1") {
		i_merkleRoot = _merkleRoot;
		i_token = _token;
	}

	/**
	* @notice Claim airdrop for an account
	* @dev Needs sign of the user, which allowed for an airdrop
	*/
	function claim(address _account, uint256 _amount, bytes32[] calldata _merkleProof, uint8 _v, bytes32 _r, bytes32 _s) external {
		// 1. Check if account already has claimed
		if (s_hasClaimed[_account]) {
			revert Airdrop__AccountAlreadyHasClaimed();
		}

		// 2. Check the signature
		if (!_isValidSignature(_account, getMessageHash(_account, _amount), _v, _r, _s)) {
			revert Airdrop__InvalidSignature();
		}

		// 3. Hash _account and _amount to produce leaf node of Merkle Tree.
		// Hash twice to avoid collisions (second preimage attack)
		bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account, _amount))));
		bool verified = MerkleProof.verify(_merkleProof, i_merkleRoot, leaf);
		if (!verified) {
			revert Airdrop__InvalidProof();
		}

		// 4. Set variables (change state)
		s_hasClaimed[_account] = true;
		emit Claimed(_account, _amount);

		// 5. Do transfer (do interactions)
		i_token.safeTransfer(_account, _amount);
	}

	function getMessageHash(address _account, uint256 _amount) public view returns (bytes32 digest) {
		return _hashTypedDataV4(
			keccak256(abi.encode(MESSAGE_TYPEHASH, Claim({ account: _account, amount: _amount})))
		);
	}

	function _isValidSignature(address _account, bytes32 _digest, uint8 _v, bytes32 _r, bytes32 _s) internal pure returns (bool) {
		(address actualSigner, , ) = ECDSA.tryRecover(_digest, _v, _r, _s);
		return actualSigner == _account;
	}

}