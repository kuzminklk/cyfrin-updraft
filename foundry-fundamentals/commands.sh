


# Anvil commands

anvil # Turn on local blockchain



# Forge commands

# Init workspace
forge init

# Compile
forge compile 
# Same as
forge build

# Run tests
forge test

# Delpoy contract
forge create StorageFactory --interactive --broadcast

# Delpoy contract via script
forge script script/DeployStorageFactory.s.sol --rpc-url sepolia --broadcast --account development

# Formatting
forge fmt



# Cast commands

# Send write transaction
cast send 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 "createStorageContract()" --rpc-url $RPC_URL

# Send read transaction
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "listsOfStorageContracts(uint256)" 1

# Turn hex into decimal
cast to-base 0x5747a dec