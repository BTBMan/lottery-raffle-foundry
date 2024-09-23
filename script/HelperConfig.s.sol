// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint96 public constant BASE_FEE = 0.2 ether;
    uint96 public constant GAS_PRICE = 1000000000;
    int256 public constant WEI_PER_UNIT_LINK = 4410411539125376;

    struct NetworkConfig {
        address vrfCoordinator;
        uint256 entranceFee;
        bytes32 keyHash;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
        bool enableNativePayment;
        uint256 interval;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory config = NetworkConfig({
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            entranceFee: 0.01 ether,
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 8413420575713347438279475371557282730552385308244088423147202136625497173362,
            callbackGasLimit: 500000,
            enableNativePayment: false,
            interval: 30
        });

        return config;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinator = new VRFCoordinatorV2_5Mock(BASE_FEE, GAS_PRICE, WEI_PER_UNIT_LINK);
        vm.stopBroadcast();

        NetworkConfig memory config = NetworkConfig({
            entranceFee: 0.01 ether,
            vrfCoordinator: address(vrfCoordinator),
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 0,
            callbackGasLimit: 500000,
            enableNativePayment: false,
            interval: 30
        });

        return config;
    }
}
