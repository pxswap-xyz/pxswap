source .env

#ETHERSCAN = $ETHERSCAN_API_KEY
#POLYGONSCAN = $PSCAN_API_KEY
#--gas-estimate-multiplier 90

forge script script/Deploy.s.sol:Deploy --chain-id 2222 --rpc-url https://rpc.kava.io \
    --broadcast --etherscan-api-key https://explorer.kava.io/api \
    --verify -vvvv --legacy