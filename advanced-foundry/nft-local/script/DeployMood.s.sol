

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";

import { Mood } from "../src/Mood.sol";


contract DeployMood is Script {

	string public HAPPY_EMODJI_SVG;
	string public SAD_EMODJI_SVG;

	function run() external returns (Mood) {
		HAPPY_EMODJI_SVG = vm.readFile("./images/happy.svg");
		SAD_EMODJI_SVG = vm.readFile("./images/sad.svg");

		vm.startBroadcast();

		Mood MoodContract = new Mood(svgToImageURI(HAPPY_EMODJI_SVG), svgToImageURI(SAD_EMODJI_SVG));

		vm.stopBroadcast();

		return MoodContract;
	}

	function svgToImageURI(string memory svg) public pure returns (string memory) {
		string memory baseImageURI = "data:image/svg+xml;base64,";
		return string.concat(baseImageURI, Base64.encode(bytes(svg)));
	}
}