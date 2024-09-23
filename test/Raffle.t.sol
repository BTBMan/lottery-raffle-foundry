// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../src/Raffle.sol";
import {RaffleScript} from "../script/Raffle.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    event RaffleEnter(address indexed player);

    Raffle public raffle;
    HelperConfig public helperConfig;

    address vrfCoordinator;
    uint256 entranceFee;
    bytes32 keyHash;
    uint256 subscriptionId;
    uint32 callbackGasLimit;
    bool enableNativePayment;
    uint256 interval;

    address user = makeAddr("user");
    uint256 constant STARTING_BALANCE = 1 ether;

    modifier prank() {
        vm.prank(user);
        _;
    }

    function setUp() public {
        (raffle, helperConfig) = new RaffleScript().run();
        (vrfCoordinator, entranceFee, keyHash, subscriptionId, callbackGasLimit, enableNativePayment, interval) =
            helperConfig.activeNetworkConfig();
        vm.deal(user, STARTING_BALANCE);
    }

    // tests
    function testRaffleInitiallizesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRevertsWhenYouDontPayEnouth() public prank {
        vm.expectRevert(Raffle.Raffle__NotEnoughETHSent.selector);

        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public prank {
        raffle.enterRaffle{value: entranceFee}();

        assertEq(raffle.getPlayer(0), user);
    }

    function testEmitsEventOnEntrance() public prank {
        vm.expectEmit(true, false, false, false, address(raffle));

        emit RaffleEnter(user);
        raffle.enterRaffle{value: entranceFee}();
    }
}
