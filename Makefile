-include .env

MAIN_CONTRACT := script/Raffle.s.sol:RaffleScript
NETWORK_ARGS :=

ifeq ($(findstring local,$(network)),local)
	NETWORK_ARGS := --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vvvv
endif

ifeq ($(findstring sepolia,$(network)),sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(REAL_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

build:; forge build

deploy:; @forge script $(MAIN_CONTRACT) $(NETWORK_ARGS)

t:; forge test

t-sepolia:
	@forge test --fork-url $(SEPOLIA_RPC_URL)

mine:; @cast rpc evm_mine --rpc-url $(RPC_URL)

recent-winner:
	@cast call 0x69142f9c95f2af85c02516ecaba3051d4facdaaf "getRecentWinner()" --rpc-url $(SEPOLIA_RPC_URL)
