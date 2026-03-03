


# Anvil commands

anvil-zksync



# Forge commands

# Deploy to local blockchain
forge script script/DeployStorageFactory.s.sol --rpc-url http://0.0.0.0:8011 --broadcast --account default --zksync

# Deploy to ZK-sync Sepolia via script
forge script script/DeployStorageFactory.s.sol --rpc-url zk-sepolia --broadcast --account development --zksync --legacy

# Deploy to ZK-sync Sepolia directly (don't work with Infura)
forge create StorageFactory --rpc-url zk-sepolia --broadcast --account development --zksync --legacy

# Use oficcial zk-sync Matter Labs RPC (work)
forge create StorageFactory --rpc-url https://sepolia.era.zksync.dev --broadcast --account development --zksync --legacy

# With verification
forge create StorageFactory --rpc-url https://sepolia.era.zksync.dev --broadcast --account development --zksync --legacy --verifier zksync --verifier-url https://explorer.sepolia.era.zksync.dev/contract_verification