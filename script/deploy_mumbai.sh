source .env

forge script script/Deploy.s.sol:Deploy --rpc-url $MUMBAI_RPC_URL \
    --broadcast --etherscan-api-key $PSCAN_API_KEY \
    --verify -vvvv