# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# resolves the conflict between test directory and test command
.PHONY: test

# deps
install:; forge install
update:; forge update

# Build & test
build  :; forge build
test   :; forge test
trace  :; forge test -vvvv
clean  :; forge clean
snapshot :; forge snapshot
gas :; forge test --gas-report
flatten :; forge flatten --output src/Pxswap.flattened.sol src/Pxswap.sol

# deploy scripts
deploy :; . script/deploy.sh
verify :; . script/verify.sh
verify-check :; . script/verify_check.sh
