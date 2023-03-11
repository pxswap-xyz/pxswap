source .env

#ETHERSCAN = $ETHERSCAN_API_KEY
#POLYGONSCAN = $PSCAN_API_KEY

forge script script/Deploy.s.sol:Deploy --rpc-url $GOERLI_RPC_URL \
    --broadcast --etherscan-api-key $ETHERSCAN_API_KEY \
    --verify -vvvv