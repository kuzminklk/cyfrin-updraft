

// SPDX-License-Identifier: MIT  

pragma solidity ^0.8.26;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract Flowers is ERC721 {
	uint256 private s_tokensCounter;
	mapping(uint256 => string) private s_tokenIdToURI;
	
	constructor() ERC721("Flowers", "FLOWERS") {
		s_tokensCounter = 0;
	}

	function mint(string memory _tokenURI) public {
		s_tokenIdToURI[s_tokensCounter] = _tokenURI;
		_safeMint(msg.sender, s_tokensCounter);
		s_tokensCounter++;
	}

	function tokenURI(uint256 tokenID) public view override returns (string memory) {
		return s_tokenIdToURI[tokenID];
	}
}