-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil zktest

build:; forge build

deploy-seploia: 
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPLOIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

