
### Description
Stablecoin
1. Relative Stability: Anchored (Pegged) to USD
   - Chainlink Price Feed
   - Function to exchange
2. Stability Mechanism (Minting): Algorithmic (Decentralized)
   - Mint with collateral
3. Collateral: Exogenous (Cryptocurrencies: wETC, wBTC)


### Status
Finished, tested locally, but don't deployed to testnet

### To-dos
- Deploy to testnet
- Write appropriate commands in ```./commands.bash```


### Set up
Install foundry dependences:  
```forge install foundry-rs/forge-std --no-git```  
```forge install openzeppelin/openzeppelin-contracts --no-git```  
```forge install ChainAccelOrg/foundry-devops --no-git``` 
```forge install smartcontractkit/chainlink-local --no-git```
```forge install smartcontractkit/chainlink-brownie-contracts --no-git```

### Deployments and interactions
Don't deploy