

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;


contract Storage {

	struct Person{
		string name;
		uint favoriteNumber;
	}

	Person[] public listOfPeople;

	mapping(string => uint) public nameToFavoriteNumber;
	
	function addPerson(string memory _name, uint _favoriteNumber) public virtual {
		listOfPeople.push(Person(_name, _favoriteNumber));
		nameToFavoriteNumber[_name] = _favoriteNumber;
	}

	// Custom getter to better use in StorageFactory.sol
	function getPerson(uint _index) public view returns(Person memory) {
		return listOfPeople[_index];
	}
}

