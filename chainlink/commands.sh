
# Deploy via forge create
forge create src/ERC20.sol:Copper --rpc-url $SEPOLIA_RPC_URL --account development-1 --broadcast

# Deploy via script
forge script script/DeployCopper.s.sol --rpc-url $SEPOLIA_RPC_URL --account development-1 --broadcast

# Call mint() function
cast send 0x1A0D56B0772327358C8a6478B764Db65B081f5e5 "mint(address,uint256)" 0xa99C9296010AfA29bBF403ec303155CADD40C601 $(cast to-unit 1ether) --rpc-url $SEPOLIA_RPC_URL --account development-1