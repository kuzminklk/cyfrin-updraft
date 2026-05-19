

// SPDX-License-Identifier: MIT  

pragma solidity ^0.8.28;


import { Script, console } from "forge-std/Script.sol";

import { Value } from "../src/Value.sol";
import { GovernanceToken } from "../src/GovernanceToken.sol";
import { Ruler } from "../src/Ruler.sol";
import { TimeLock } from "../src/TimeLock.sol";


/**
 * @notice Deploy contracts
 */
contract Deploy is Script {
	uint256 constant public TIMELOCK_DELAY = 50400; // In blocks, equal 1 week with 15 seconds block time
	
	function run(address _deployer) public {
		vm.startBroadcast(_deployer);
			deploy(_deployer);
		vm.stopBroadcast();
	}

	function deploy(address _deployer) public returns(Value, GovernanceToken, Ruler, TimeLock) {
		console.log(unicode"“msg.sender” for “deploy” is: %s", msg.sender);
		console.log(unicode"“tx.origin” for “deploy” is: %s", tx.origin);

		Value valueContract;
		GovernanceToken governanceTokenContract;
		Ruler rulerContract;
		TimeLock timeLockContract;

		address[] memory proposers;
		address[] memory executors;

		valueContract = new Value();
		governanceTokenContract = new GovernanceToken();
		governanceTokenContract.delegate(_deployer);
		timeLockContract = new TimeLock(TIMELOCK_DELAY, proposers, executors);
		rulerContract = new Ruler(governanceTokenContract, timeLockContract);

		timeLockContract.grantRole(timeLockContract.PROPOSER_ROLE(), address(rulerContract));
		timeLockContract.grantRole(timeLockContract.EXECUTOR_ROLE(), address(0));
		timeLockContract.revokeRole(timeLockContract.DEFAULT_ADMIN_ROLE(), _deployer);

		valueContract.transferOwnership(address(timeLockContract));

		return (valueContract, governanceTokenContract, rulerContract, timeLockContract);
	}
}