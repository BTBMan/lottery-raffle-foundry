// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../src/Raffle.sol";

contract RaffleTest is Test {
    Raffle public raffle;

    function setUp() public {
        raffle = new Raffle();
    }
}
