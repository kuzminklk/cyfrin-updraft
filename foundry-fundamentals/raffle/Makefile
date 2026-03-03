
-include .env

.PHONY: all test deploy

build:; forge build

test:; forge test

deploy-sepolia:
	@forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url sepolia --account development --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv
# 	forge script script/Deploy.s.sol --rpc-url sepolia --broadcast --account development --verify --etherscan-api-key ${ETHERSCAN_API_KEY}

install:
	forge install foundry-rs/forge-std --no-git;
	forge install Cyfrin/foundry-devops --no-git;
	forge install smartcontractkit/chainlink-brownie-contracts --no-git;
	forge install transmissions11/solmate --no-git;