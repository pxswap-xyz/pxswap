source .env

export CONTRACT=0xf8d59ea68cb19d16bd66300cb49955479e45f879
export ARG=0x2B68407d77B044237aE7f99369AA0347Ca44B129
export SHARDEUM=https://liberty20.shardeum.org/

#cast send --private-key=$LOCAL_PRIVATE_KEY $FACTORYERC20SB "setMintPrice(uint256)" $MINT_PRICE --rpc-url $LOCAL_RPC_URL --legacy

cast send --private-key=$PRIVATE_KEY $CONTRACT "setProtocol(address)" $ARG --rpc-url $GOERLI_RPC_URL