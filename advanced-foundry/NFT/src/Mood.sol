

// SPDX-License-Identifier: MIT  

pragma solidity ^0.8.26;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";


contract Mood is ERC721 {

	uint256 private s_tokensCounter;

	// Image URIs (SVGs in Base64)
	string private s_happyEmodji;
	string private s_sadEmodji;

	enum Mood {
		HAPPY,
		SAD
	}

	mapping(uint256 => Mood) private s_tokenIdToMood;
	
	constructor(string memory _happyEmodji,string memory _sadEmodji) ERC721("Moods", "MOODS") {
		s_tokensCounter = 0;

		s_happyEmodji = _happyEmodji;
		s_sadEmodji = _sadEmodji;
	}

	function flipMood(uint256 tokenId) public {
		address owner = ownerOf(tokenId);
		_checkAuthorized(owner, msg.sender, tokenId);
		
		if(s_tokenIdToMood[tokenId] == Mood.HAPPY) {
			s_tokenIdToMood[tokenId] = Mood.SAD;
		} else {
			s_tokenIdToMood[tokenId] = Mood.HAPPY;
		}
	}

	function mint() public {
		_safeMint(msg.sender, s_tokensCounter);
		s_tokenIdToMood[s_tokensCounter] = Mood.HAPPY;
		s_tokensCounter++;
	}

	function _baseURI() internal pure override returns (string memory) {
		return "data:application/json;base64,";
	}

	function imageURI(uint256 tokenId) public view returns (string memory) {
		return s_tokenIdToMood[tokenId] == Mood.HAPPY ? s_happyEmodji : s_sadEmodji;

	}

	function tokenURI(uint256 tokenId) public view override returns (string memory) {

		// Checks
		_requireOwned(tokenId);

		return 
			string.concat(
				 _baseURI(),
				Base64.encode(
					bytes(
						string.concat(
							'{"name": "', name(),'", "description":"An NFT that reflects the owner mood.", "attributes":[{"trait_type":"moodiness", "value": 100}], "image":"', imageURI(tokenId), '"}'
						)
					)
				)
			);
	}
}