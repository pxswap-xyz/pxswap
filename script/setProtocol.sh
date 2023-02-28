source .env

#export FACTORYERC20SB=0xCa7cA7BcC765F77339bE2d648BA53ce9c8a262bD
export CONTRACT=0xb1bb87ff47988c3ca10822d13e0ce7a381c40974
export ARG=0x2B68407d77B044237aE7f99369AA0347Ca44B129

#cast send --private-key=$LOCAL_PRIVATE_KEY $FACTORYERC20SB "setMintPrice(uint256)" $MINT_PRICE --rpc-url $LOCAL_RPC_URL

cast send --private-key=$PRIVATE_KEY $CONTRACT "setProtocol(address)" $ARG --rpc-url https://liberty20.shardeum.org/ --legacy