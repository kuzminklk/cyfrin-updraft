
### Description
Smart-contract upgradability implementation via UUPS from OpenZeppelin  

### Technologies
Proxy → UUPS, ERC-1967  


### Status
Finished, tested locally, deployed to testnet and tested  


### Set Up
Install Foundry dependences:
```forge install foundry-rs/forge-std@v1.16.1 --no-git```   
```forge install openzeppelin/openzeppelin-contracts@v5.6.1 --no-git```  
```forge install openzeppelin/openzeppelin-contracts-upgradeable@v5.6.1 --no-git```  
```forge install cyfrin/foundry-devops@0.4.0 --no-git```  

### Usage
Basic Foundry commands: ```forge build```, ```forge test```  
Other appropriate commands in ```./commands.bash```  

### Deployments and interactions
Addresses and hashes at ```./interactions.md``` and more deep information at ```./broadcast/```  