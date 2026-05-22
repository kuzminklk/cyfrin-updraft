
### Description
Implementation of DAO. Built by OpenZeppelin Wizzard

### Technologies
OpenZeppelin


### Status
Finished, tested locally, but not deployed to testnet  
Issue with deployment  

### Development Path
1. Finished course materials
2. Tried to create deploy script and deploy to testnet, met an issue (contract size limit and mess with “msg.sender” and “tx.origin”)

### To-dos
- Solve deploy problems in Foundry
- Rebuild project in Hardhat with more clear scripts


### Set Up
Install Foundry dependences:  
```forge install foundry-rs/forge-std --no-git```   
```forge install openzeppelin/openzeppelin-contracts --no-git```  

### Usage
Basic Foundry commands: ```forge build```, ```forge test```  
Other appropriate commands in ```./commands.bash```  

### Deployments
Don't do deployment, script doesn't works correctly (meet contract size limit issue and mess with “msg.sender” and “tx.origin”)  