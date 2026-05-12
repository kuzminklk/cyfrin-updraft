
### Description
Rebase Token with CCIP cross-chain functionality

### Technologies
CCIP, Chainlink Local

### Development Path
1. Doesn't work. Unknown bug, error with Chainlink Local functionality. Maybe I will rebuild with Hardhat
2. Fix the bug. It was issue of latest chainlink-local versions. Use beta-version of that instead

### Set up
Install foundry dependences:
```forge install foundry-rs/forge-std --no-git```
```forge install smartcontractkit/chainlink-local@v0.2.9-beta.0 --no-git``` (Beta-version, where the bug was fixed)
```forge install smartcontractkit/chainlink-evm --no-git```
```forge install smartcontractkit/chainlink-ccip --no-git```
```forge install openzeppelin/openzeppelin-contracts --no-git```  