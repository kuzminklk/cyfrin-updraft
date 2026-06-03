
### Description
Account abstractions for Ethereum  

### Technologies
ERC-4337  


### Status
Finished, tested locally, deployed to testnet and tested  

### To-dos
1. Test account-abstraction functionality via alt-mempool and “Entry Point” contract  


### Set Up
Install Foundry dependences:  
```forge install foundry-rs/forge-std@v1.16.1 --no-git```   
```forge install eth-infinitism/account-abstraction@v0.9.0 --no-git```  
```forge install openzeppelin/openzeppelin-contracts@v5.6.1 --no-git```  

### Usage
Basic Foundry commands: ```forge build```, ```forge test```  
Other appropriate commands in ```./commands.bash```  

### Deployments and interactions
Addresses and hashes at ```./interactions.md``` and more deep information at ```./broadcast/```  