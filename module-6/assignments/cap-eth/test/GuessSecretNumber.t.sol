// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/GuessSecretNumber.sol";

contract GuessNumberTest is Test {
    GuessTheSecretNumberChallenge target;
    address player = vm.addr(1);

    function setUp() public {
        target = new GuessTheSecretNumberChallenge{value: 1 ether}();
        vm.deal(player, 1 ether);
    }

    function testChallenge() public {
        bytes32 answerHash = 0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;

        uint8 answer;
        for (uint8 i; answer <= type(uint8).max; ++i) {
            if (keccak256(abi.encodePacked(i)) == answerHash) {
                answer = i;
                break;
            }
        }
        vm.startPrank(address(player));
        target.guess{value: 1 ether}(answer);
        assertTrue(target.isComplete());
    }
}
