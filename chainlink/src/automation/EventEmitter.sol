

// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.26;


contract EventEmitter {  
    event WantsToCount(address indexed msgSender);

    constructor() {}

    function emitCountEvent() public {  
        emit WantsToCount(msg.sender);  
    }  
}