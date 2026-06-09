
-include .env

build:; forge build

deploy-sepolia:
	forge script script/Deploy.s.sol --rpc-url sepolia --broadcast --account development --verify --etherscan-api-key ${ETHERSCAN_API_KEY}

install:
	forge install foundry-rs/forge-std --no-git;
	forge install smartcontractkit/chainlink-brownie-contracts --no-git;
	forge install Cyfrin/foundry-devops --no-git;