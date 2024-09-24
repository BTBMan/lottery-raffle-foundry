-include .env

MAIN_CONTRACT := script/Raffle.s.sol:RaffleScript
NETWORK_ARGS :=

ifeq ($(findstring local,$(network)),local)
	NETWORK_ARGS := --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --broadcast
endif

ifeq ($(findstring sepolia,$(network)),sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(REAL_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY)
endif

build:; forge build

deploy:; @forge script $(MAIN_CONTRACT) $(NETWORK_ARGS)

t:; forge test

test-fork-sepolia:
	@forge test --fork-url $(SEPOLIA_RPC_URL)
