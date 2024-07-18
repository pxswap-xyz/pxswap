source .env

forge script script/DeployPxswap.s.sol:DeployPxswap --chain-id 137 --rpc-url https://polygon.llamarpc.com \
    --broadcast --etherscan-api-key $POLYGONSCAN_API_KEY \
    --verify -vvvv