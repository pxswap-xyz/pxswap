source .env

forge script script/DeployPxswap.s.sol:DeployPxswap --chain-id 1 --rpc-url https://rpc.ankr.com/optimism \
    --broadcast --etherscan-api-key $ETHERSCAN_API_KEY \
    --verify -vvvv