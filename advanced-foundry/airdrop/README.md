
### Description
Airdrop via Merkel Tree and functionality to sign via ECDSA  

### Technologies
Merkle Tree, ERC-191, ERC-712, ECDSA  

### Development Path
1. Complete project from course materials
2. Add “sign” for “msg.sender”
3. Add functionality to change Merkle Root from the owner, rebuild tests

### Set Up
Install Foundry dependences:  
```forge install openzeppelin/openzeppelin-contracts --no-git```  
```forge install dmfxyz/murky --no-git```  
```forge install cyfrin/foundry-devops --no-git```  

### Usage
Basic Foundry commands: ```forge build```, ```forge test```  
Other appropriate commands in ```./commands.bash```  
Additional:
1. Add allowed addresses into ```./script/target/input.json``` or run script “Generate Input”  
2. Generate Merkle Tree for that input via ```./script/target/GenerateMerkleTree```
3. Use Merkle Root when deploy contract  
4. Use Merkle Proof to run “claim” for allowed address  

### Deployments
Addresses and hashes at ```./deployments.md``` and more deep information at ```./broadcast/```  