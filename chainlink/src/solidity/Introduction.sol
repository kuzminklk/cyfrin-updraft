

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;


// ——— Variables ———

// — Storage Variables —
contract StorageVariables {
	// Public. Solidity creates a getter
	uint256 public s_number = 200;
	string public s_string = "Hello!";
	bool public s_isActive = true;
	address public s_owner;

	// Private. Not accessible from other contracts. Can be read in code.
	uint256 private s_userNumber = 2000;

	// Internal. Can be accessible from child contracts
	uint256 internal s_contractNumber = 3000; 
}

// — Constant Variables —
contract ConstantVariables {
	// Only value types
	uint256 public constant PRICE = 4000;
}

// — Immutable Variables —
contract ImmutableVariables {
	address public immutable DEPLOYER;

	constructor() {
		DEPLOYER = msg.sender;
	}
}

//	— Value types —
/*
	Store value
		uint
		int
		bool
		address
		bytes32
*/
	
// — Reference types — 
/*
	Store pointer
		string
		arrays
		mapping
		struct
		bytes
*/

// — Storage Locations

contract ReferenceTypes {
	uint256[] public s_scores = [10, 20, 50];

	function processScores(uint256[] calldata c_input) public { // Calldata. Read-only. Good for external parameters, that don't be changed
		uint256[] storage s_scoresPointer = s_scores;
		s_scoresPointer[0] = 30; // [30, 20, 50]

		uint256[] memory m_scoresMemory = s_scoresPointer; // Memory Location
		m_scoresMemory[0] = 100;

		/*
		s_scores, s_scoresPointer = [30, 20, 50]
		m_scoresMemory = [100, 20, 50]
		*/
	}
}


// ——— Functions ———

/* 
	Visibility: public, private, internal, external
	Mutability: payable, view, pure
*/


// ——— Transaction Context And Global Variables ———

// — Transaction Context —
/* 
	msg.sender — sender
	msg.value — value, only for payable
	msg.data — all calldata

*/

// — Block Information —
/*
	block.timestamp — current block timestamp
	block.number — current block number
*/


// ——— Control Structures ———
/* 
	Conditions (if)
	Loops (for, while)
*/


// ——— Errors Handling ———

contract ErrorsHandling {
	// require()

	error InsufficentBalance(address user);

	mapping(address => uint256) public balances;

	function withdraw(uint256 amount) public {
		if(balances[msg.sender] < amount) {
			revert InsufficentBalance(msg.sender);
		}
	}
}


// ——— Events ———

contract Token {
	// «indexed» keyword makes search easier
	event Transfer(address indexed from, address indexed to, uint256 amount);

	mapping(address => uint256) public s_balances;

	function transfer(address to, uint256 amount) public {
		s_balances[msg.sender] -= amount;
		s_balances[to] += amount;
	}
}


// ——— Modifiers ———

contract Owner {
	address public s_owner;

	constructor() {
		s_owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == s_owner, "Not the owner");
		_;
	}

	function setOwner(address newOwner) public {
		s_owner = newOwner;
	}
}


// ——— Interfaces ———

interface InterfacePayable {
	function pay(address recipient, uint256 amount) external returns (bool);
	function getBalance(address account) external view returns (uint256);
}

contract PaymentProcessor is InterfacePayable {
	mapping(address => uint256) private balances;

	function pay(address recipient, uint256 amount) external override returns (bool) {
		require(balances[msg.sender] >= amount, "Insufficent balance");
		balances[msg.sender] -= amount;
		balances[recipient] += amount;
		return true;
	}

	function getBalance(address account) external view override returns (uint256) {	
		return balances[account];
	}

}

