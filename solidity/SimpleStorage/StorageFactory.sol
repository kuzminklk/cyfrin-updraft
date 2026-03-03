

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Storage } from "./Storage.sol";


contract StorageFactory {

	Storage[] public listsOfStorageContracts;

	function createSimpleStorageContract() public {
		Storage newStorage = new Storage();
		listsOfStorageContracts.push(newStorage);
	}

	function addPersonToStorage(uint _contractId, string memory _name, uint _favoriteNumber) public {
		listsOfStorageContracts[_contractId].addPerson(_name, _favoriteNumber);
	}

	function getPersonFromStorage(uint _contractIndex, uint _peopleId) public view returns(Storage.Person memory) {
		return listsOfStorageContracts[_contractIndex].getPerson(_peopleId);
	}
}