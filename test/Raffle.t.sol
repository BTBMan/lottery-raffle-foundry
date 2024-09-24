// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
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

    function testCantEnterWhenRaffleIsCalculating() public prank {
        raffle.enterRaffle{value: entranceFee}();

        vm.warp(block.timestamp + interval + 1); // increase the block time
        vm.roll(block.number + 1); // add a block

        raffle.performUpkeep("");

        vm.expectRevert(Raffle.Raffle__NotOpen.selector);

        raffle.enterRaffle{value: entranceFee}();
    }

    function testCheckUpkeepReturnsFalseIfItHasNoBalance() public {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        (bool upkeepNeeded,) = raffle.checkUpkeep("");

        assertEq(upkeepNeeded, false);
    }

    function testCheckUpkeepReturnsFalseIfRaffleNotOpen() public prank {
        raffle.enterRaffle{value: entranceFee}();

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        raffle.performUpkeep("");

        (bool upkeepNeeded,) = raffle.checkUpkeep("");

        assertEq(upkeepNeeded, false);
    }

    function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue() public prank {
        raffle.enterRaffle{value: entranceFee}();

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        raffle.performUpkeep("");
    }

    function testPerformUpkeepRevertIfCheckUpkeepIsFalse() public prank {
        vm.expectRevert(abi.encodeWithSelector(Raffle.Raffle__UpkeepNotNeeded.selector, 0, 0, 0));
        raffle.performUpkeep("");
    }

    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId() public prank {
        raffle.enterRaffle{value: entranceFee}();

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        vm.recordLogs();

        raffle.performUpkeep("");

        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        assert(uint256(requestId) > 0);
        assertEq(uint256(raffle.getRaffleState()), 1);
    }
}
