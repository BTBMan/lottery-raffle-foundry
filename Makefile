-include .env

build:; forge build

deploy:; forge script script/Raffle.s.sol

deploy-local:
	forge script script/Raffle.s.sol --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --broadcast

deploy-sepolia:
	forge script script/Raffle.s.sol --rpc-url $(SEPOLIA_RPC_URL) --private-key $(REAL_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY)