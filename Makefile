# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# deps
install:; forge install
update:; forge update

# Build & test
build  :; forge build
test   :; forge test
trace  :; forge test -vvv
clean  :; forge clean
snapshot :; forge snapshot
gas :; forge test --gas-report
flatten :; forge flatten --output src/Pxswap.flattened.sol src/Pxswap.sol

# deploy scripts
deploy :; . script/deploy.sh
deploy-local :; . script/deploy_local.sh
dg :; . script/deploy_goerli.sh
ds :; . script/deploy_shardeum.sh
dm :; . script/deploy_mumbai.sh
deploy-polygon :; . script/deploy_polygon_mainnet.sh
deploy-eth :; . script/deploy_mainnet.sh
verify :; . script/verify.sh
verify-check :; . script/verify_check.sh

# calls
setp :; . script/setProtocol.sh