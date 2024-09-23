// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract RaffleScript is Script {
    function setUp() public {}

    function run() public returns (Raffle) {
        (
            address vrfCoordinator,
            uint256 entranceFee,
            bytes32 keyHash,
            uint256 subscriptionId,
            uint32 callbackGasLimit,
            bool enableNativePayment,
            uint256 interval
        ) = new HelperConfig().activeNetworkConfig();

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            vrfCoordinator, entranceFee, keyHash, subscriptionId, callbackGasLimit, enableNativePayment, interval
        );
        vm.stopBroadcast();

        return raffle;
    }
}
