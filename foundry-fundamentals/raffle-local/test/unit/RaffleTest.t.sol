

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19; 

import { Test } from "forge-std/Test.sol";
import { Vm } from "forge-std/Vm.sol";
import { VRFCoordinatorV2_5Mock } from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

import { Raffle } from "src/Raffle.sol";
import { DeployRaffle } from "script/DeployRaffle.s.sol";
import { HelperConfig, Constants } from "script/HelperConfig.s.sol";


contract RaffleTest is Test, Constants {
	Raffle public raffle;
	HelperConfig public helperConfig;
	HelperConfig.NetworkConfig public networkConfig;

	// Events for testing
	event RaffleEntered(address indexed player);


	function setUp() external {
		DeployRaffle deployer = new DeployRaffle();
		(raffle, helperConfig) = deployer.deployContract();
		networkConfig = helperConfig.getNetworkConfig();

		vm.deal(TEST_USER, TEST_STARTING_BALANCE);
	}

	function testRaffleInitializesInOpenState()	public view {
		assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
	}


	/* —————— Modifiers —————— */

	modifier userEnterRaffleWithFee() {
		vm.prank(TEST_USER);
		raffle.enterRaffle{value: networkConfig.entranceFee}();
		_;
	}

	modifier timeHasPassed() {
		vm.warp(block.timestamp + networkConfig.interval + 1);
		vm.roll(block.number + 1);
		_;
	}

	modifier skipFork() {
		if(block.chainid != ANVIL_CHAIN_ID) {
			return;
		}
		_;
	}



	/* —————— Enter Raffle Tests —————— */

	function testRaffleRevertsWhenUserPayNotEnough() public {
		// Arrange
		vm.prank(TEST_USER);

		// Act & Assert
		vm.expectRevert(Raffle.Raffle__NotEnoughEthToEnterRaffle.selector);
		raffle.enterRaffle();
	}

	function testRaffleRecordsPlayersWhenTheyEnter() public {
		// Arrange
		vm.prank(TEST_USER);

		// Act
		raffle.enterRaffle{value: networkConfig.entranceFee}();

		// Assert
		assert(TEST_USER == raffle.getPlayer(0));
	}

	function testEnteringRaffleEmitsEvent() public {
		vm.prank(TEST_USER);

		// Act & Assert
		vm.expectEmit(true, false, false, false, address(raffle));
		emit RaffleEntered(TEST_USER);

		raffle.enterRaffle{value: networkConfig.entranceFee}();
	}

	function testDontAllowUsersToEnterWhileRaffleIsCalculating() public userEnterRaffleWithFee timeHasPassed {
		// Act & Assert
		raffle.performUpkeep("");

		vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
		vm.prank(TEST_USER);
		raffle.enterRaffle{value: networkConfig.entranceFee}();
	}


	/* —————— Check Upkeep Tests —————— */

	function testCheckUpkeepReturnsFalseIfRaffleHasNoBalance() public timeHasPassed {
		// Act
		(bool upkeepNeeded, ) = raffle.checkUpkeep("");

		// Assert
		assert(!upkeepNeeded);
	}

	function testCheckUpkeepReturnsFalseIfRaffleIsntOpen() public userEnterRaffleWithFee timeHasPassed {
		// Arrange
		raffle.performUpkeep("");

		// Act
		(bool upkeepNeeded, ) = raffle.checkUpkeep("");

		// Assert
		assert(!upkeepNeeded);
	}

	function testCheckUpkeepReturnsFalseIfTimeDosentPass() public userEnterRaffleWithFee {
		// Act
		(bool upkeepNeeded, ) = raffle.checkUpkeep("");

		// Assert
		assert(!upkeepNeeded);
	}

	function testCheckUpkeepReturnsTrueIfAllParametersAreOk() public userEnterRaffleWithFee timeHasPassed {
		// Act
		(bool upkeepNeeded, ) = raffle.checkUpkeep("");

		// Assert
		assert(upkeepNeeded);
	}


	/* —————— Perform Upkeep Tests —————— */

	function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue() public userEnterRaffleWithFee timeHasPassed {
		// Acr & Assert
		raffle.performUpkeep("");
	}

	function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
		// Arrange
		uint256 balance = 0;
		uint256 numberOfPlayers = 0;
		Raffle.RaffleState raffleState = raffle.getRaffleState(); 

		// Act & Assert
		vm.expectRevert(
			abi.encodeWithSelector(Raffle.Raffle__UpkeepNotNeeded.selector, balance, numberOfPlayers, raffleState)
		);
		raffle.performUpkeep("");
	}

	function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId() public userEnterRaffleWithFee timeHasPassed {
		// Act
		vm.recordLogs();
		raffle.performUpkeep("");
		Vm.Log[] memory entries = vm.getRecordedLogs();
		bytes32 requestId = entries[1].topics[1];

		// Assert
		assert(uint256(requestId) > 0);
		assert(raffle.getRaffleState() == Raffle.RaffleState.CALCULATING);
	}


	/* —————— Fulfill Random Words Tests —————— */

	function testFulfilRandomWordsCanOnlyBeCalledAfterPerformUpkeep(uint256 randomRequestId) public userEnterRaffleWithFee timeHasPassed skipFork {
		// Arrange & Act & Assert
		vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
		VRFCoordinatorV2_5Mock(networkConfig.vrfCoordinatorContract).fulfillRandomWords(randomRequestId, address(raffle));
	}

	function testFullfilRandomWordsPicksWinnerAndResetsAndSendsMoney() public userEnterRaffleWithFee timeHasPassed skipFork {
		// Arrange
		uint256 additionalEntrants = 3; // 4 total;
		uint256 startingIndex = 1;
		address expectedWinner = address(1);

		for(uint256 i = startingIndex; i < startingIndex + additionalEntrants; i++ ) {
			address user = address(uint160(i));
			hoax(user, 1 ether);
			raffle.enterRaffle{value: networkConfig.entranceFee}();
		}

		uint256 startingTimeStamp = raffle.getLastTimeStamp();
		uint256 winnerStartingBalance = expectedWinner.balance;

		// Act
		vm.recordLogs();
		raffle.performUpkeep("");
		Vm.Log[] memory entries = vm.getRecordedLogs();
		bytes32 requestId = entries[1].topics[1];

		VRFCoordinatorV2_5Mock(networkConfig.vrfCoordinatorContract).fulfillRandomWords(uint256(requestId), address(raffle));

		// Assert
		address recentWinner = raffle.getRecentWinner();
		Raffle.RaffleState raffleState = raffle.getRaffleState();
		uint256 winnerBalance = recentWinner.balance;
		uint256 endingTimeStamp = raffle.getLastTimeStamp();
		uint256 prize = networkConfig.entranceFee * (additionalEntrants + 1);

		assert(recentWinner == expectedWinner);
		assert(raffleState == Raffle.RaffleState.OPEN);
		assert(winnerBalance == winnerStartingBalance + prize);
		assert(endingTimeStamp > startingTimeStamp);
	}
}