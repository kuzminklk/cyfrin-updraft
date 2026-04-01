

# ——— Deploy ———

# — Flowers —
forge script script/DeployFlowers.s.sol --rpc-url sepolia --account development-1 --broadcast --verify


# ——— Interactions ———

# — Flowers —
# Mint Pink Rose
forge script script/Interactions.s.sol:MintPinkRose --rpc-url sepolia --account development-1 --broadcast --verify