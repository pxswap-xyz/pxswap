source .env

forge verify-contract 0x03269BAE56E35f130eA826C6d2AA94265d1e660F Pxswap \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --watch \
    --retries=2 \
    --verifier-url=https://api.routescan.io/v2/network/testnet/evm/80085/etherscan/api/;