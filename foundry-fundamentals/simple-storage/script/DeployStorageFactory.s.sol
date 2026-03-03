// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "../lib/forge-std/src/Script.sol";
import {StorageFactory} from "../src/StorageFactory.sol";

contract DeployStorageFactory is Script {
    function run() external returns (StorageFactory) {
        vm.startBroadcast();
        StorageFactory storageFactory = new StorageFactory();
        vm.stopBroadcast();
        return storageFactory;
    }
}
