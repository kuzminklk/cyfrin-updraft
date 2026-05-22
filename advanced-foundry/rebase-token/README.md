
### Description
Rebase Token with CCIP cross-chain functionality

### Technologies
CCIP, Chainlink Local


### Status
Finished at 90%, tested locally, don't deploy to testnet

### Development Path
1. Didn't worked. Unknown bug, error with Chainlink Local functionality. Maybe I will rebuild with Hardhat
2. Fixed the bug. It was issue of latest chainlink-local versions. Use beta-version of that instead

### To-dos
- Rewatch lessons from 29
- Deploy to testnet


### Set up
Install foundry dependences:
```forge install foundry-rs/forge-std --no-git```
```forge install smartcontractkit/chainlink-local@v0.2.9-beta.0 --no-git``` (Beta-version, where the bug was fixed)
```forge install smartcontractkit/chainlink-evm --no-git```
```forge install smartcontractkit/chainlink-ccip --no-git```
```forge install openzeppelin/openzeppelin-contracts --no-git```  

### Deployments and interactions
Don't deploy now