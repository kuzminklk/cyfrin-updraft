

# ——— Deploy ———

# — ERC20 (Copper) —
# Deploy via forge create
forge create src/ERC20.sol:Copper --rpc-url $SEPOLIA_RPC_URL --account development-1 --broadcast

# Deploy via script
forge script script/DeployCopper.s.sol --rpc-url $SEPOLIA_RPC_URL --account development-1 --broadcast

# — Market —
forge script script/DeployMarket.s.sol --rpc-url $SEPOLIA_RPC_URL --account development-1 --broadcast

# — Counter —
forge script script/DeployCounter.s.sol --rpc-url sepolia --account development-1 --broadcast --verify

# — Counter With Custom Logic —
forge script script/DeployCounterWithCustomLogic.s.sol --rpc-url sepolia --account development-1 --broadcast --verify

# — Event Emitter —
forge script script/DeployEventEmitter.s.sol --rpc-url sepolia --account development-1 --broadcast --verify

# — Event Counter —
forge script script/DeployCounter.s.sol --rpc-url sepolia --account development-1 --broadcast --verify

# — Token Sender —
forge script script/DeployTokenSender.s.sol --rpc-url sepolia --account development-1 --broadcast --verify

# — Vault —
forge script script/DeployVault.s.sol --rpc-url base-sepolia --account development-1 --broadcast --verify

# — Message Sender —
forge script script/DeployMessageSender.s.sol --rpc-url sepolia --account development-1 --broadcast --verify

# — Message Reciver —
forge script script/DeployMessageReciver.s.sol --rpc-url base-sepolia --account development-1 --broadcast --verify

# — Consumer —
forge script script/DeployConsumer.s.sol --rpc-url sepolia --account development-1 --broadcast --verify

# — House Picker  —
forge script script/DeployHousePicker.s.sol --rpc-url sepolia --account development-1 --broadcast --verify


# ——— Call functions (Change state) ———

# — ERC20 (Copper) —
# Call mint() function
cast send 0x1A0D56B0772327358C8a6478B764Db65B081f5e5 "mint(address,uint256)" 0xa99C9296010AfA29bBF403ec303155CADD40C601 $(cast to-unit 1ether) --rpc-url $SEPOLIA_RPC_URL --account development-1

# Call grantRole() function
cast send 0x1A0D56B0772327358C8a6478B764Db65B081f5e5 "grantRole(bytes32,address)" 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6 0xD168401148Af1f54aD474C50E77E95844274Ee96 --rpc-url sepolia --account development-1

# — Market —
# Send value for 
cast send 0xD168401148Af1f54aD474C50E77E95844274Ee96 --value 0.001ether --rpc-url sepolia --account development-1


# ——— Read Variables (Don't change state) ———

# — ERC20 (Copper) —
# Call hasRole()
cast call 0x1A0D56B0772327358C8a6478B764Db65B081f5e5 "hasRole(bytes32,address)" 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6 0xD168401148Af1f54aD474C50E77E95844274Ee96 --rpc-url sepolia --account development-1

# — Market —
# Call getChainlinkDataFeedLatestAnswer()
cast call 0xD168401148Af1f54aD474C50E77E95844274Ee96 "getChainlinkDataFeedLatestAnswer()" --rpc-url sepolia --account development-1


# ——— Verify Contract ———

# — Counter —
forge verify-contract --chain sepolia 0x5564ee43Da2D3168773eC80ca7F6990E6a1522F2 src/automation/Counter.sol:Counter

# — House Picker  —
forge verify-contract --chain sepolia 0x21D2BCf19056C1bE9f2170EF45A1A0873c0E52cF src/vrf/HousePicker.sol:HousePicker