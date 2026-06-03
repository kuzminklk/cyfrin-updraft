
# Create Merkle Tree with proods from “input.json”
forge script ./script/GenerateMerkleTree.s.sol:GenerateMerkleTree

# Deploy with appropriate Merkle Root
forge script ./script/Deploy.s.sol 0xa31798c6da0ebbffd07744035fe5112c833065fbaddc07300d83095636ba9ae2 --rpc-url sepolia --account development-1 --broadcast --verify

# Claim

forge script ./script/Claim.s.sol 0xc79Ec4E877f07B3559D2C130362cf339cAC3b550 [0x74d92addd4f9e5f6eca2c8d15e5935143d24966e5fe49f573d43cab950ea9996, 0xaad9d098f3da746f10a3754950e97584083b9dbf4cff41b2ab442de34400cbe7] --rpc-url sepolia --account development-1 --broadcast --verify