// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Storage} from "./Storage.sol";

contract AddFiveStorage is Storage {
	function addPerson(string memory _name, uint256 _favoriteNumber) public override {
		listOfPeople.push(Person(_name, _favoriteNumber));
		nameToFavoriteNumber[_name] = _favoriteNumber + 5;
	}
}
