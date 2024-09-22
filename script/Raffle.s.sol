// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

contract RaffleScript is Script {
    function setUp() public {}

    function run() public returns (Raffle) {
        vm.startBroadcast();

        Raffle raffle = new Raffle();

        vm.stopBroadcast();

        return raffle;
    }
}
