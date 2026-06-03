
# Deploy
forge script ./script/Deploy.s.sol --rpc-url sepolia --account development-1 --broadcast

# Verify
forge verify-contract 0x2E9D4A06Afe00dFc93eba260425A4D946aa4b077 lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy --rpc-url sepolia

forge verify-contract 0x2E9D4A06Afe00dFc93eba260425A4D946aa4b077 ./src/Value.sol:Value --rpc-url sepolia

forge verify-contract 0xD45387A8cF3C914A2B23CEB2FBcBD0414b409cA7 ./src/ValueMultiplication.sol:ValueMultiplication --rpc-url sepolia

# Upgrade
forge script ./script/Upgrade.s.sol --rpc-url sepolia --account development-1 --broadcast