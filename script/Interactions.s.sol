// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256) {
        HelperConfig helpConfig = new HelperConfig();
        (address vrfCoordinator,,,,,,) = helpConfig.activeNetworkConfig();

        return createSubscription(vrfCoordinator);
    }

    function createSubscription(address vrfCoordinator) public returns (uint256) {
        vm.startBroadcast();
        uint256 subscriptionId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();

        return subscriptionId;
    }

    function run() public returns (uint256) {
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script {
    function fundSubscription(address vrfCoordinator, uint256 subId) public {
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subId, 1e18);
        vm.stopBroadcast();
    }

    function run() public {}
}

contract AddConsumer is Script {
    function addConsumer(address raffle, address vrfCoordinator, uint256 subId) public {
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subId, raffle);
        vm.stopBroadcast();
    }

    function run() public {}
}
