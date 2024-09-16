source .env

forge verify-contract 0x03269BAE56E35f130eA826C6d2AA94265d1e660F Pxswap \
    --chain-id 137 \
    --etherscan-api-key $ARBISCAN_API_KEY \
    --watch \
    --retries=2 