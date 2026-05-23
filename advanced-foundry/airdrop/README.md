
### Description
Airdrop via Merkel Tree and functionality to sign via ECDSA  

### Technologies
Merkle Tree, ERC-191, ERC-712, ECDSA  


### Status
Finished, tested locally, deployed to testnet and tested

### Development Path
1. Completed project from course materials
2. Added “sign” for “msg.sender”
3. Added functionality to change Merkle Root from the owner, rebuild tests


### Set Up
Install Foundry dependences:  
```forge install foundry-rs/forge-std@v1.16.1 --no-git``` 
```forge install openzeppelin/openzeppelin-contracts@v5.6.1 --no-git```  
```forge install dmfxyz/murky@v0.1.0 --no-git```  
```forge install cyfrin/foundry-devops@0.4.0 --no-git```  

### Usage
Basic Foundry commands: ```forge build```, ```forge test```  
Other appropriate commands in ```./commands.bash```  
Additional:
1. Add allowed addresses into ```./script/target/input.json``` or run script “Generate Input”  
2. Generate Merkle Tree for that input via ```./script/target/GenerateMerkleTree```
3. Use Merkle Root when deploy contract  
4. Use Merkle Proof to run “claim” for allowed address  

### Deployments and interactions
Addresses and hashes at ```./interactions.md``` and more deep information at ```./broadcast/```  