source .env

forge script script/DeployPxswap.s.sol:DeployPxswap --chain-id 11155111 --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
    --broadcast --etherscan-api-key $ETHERSCAN_API_KEY \
    --verify -vvvv