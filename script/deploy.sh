source .env

forge script script/DeployPxswap.s.sol:DeployPxswap --chain-id 5 --rpc-url https://rpc.ankr.com/eth_goerli \
    --broadcast --etherscan-api-key $ETHERSCAN_API_KEY \
    --verify -vvvv