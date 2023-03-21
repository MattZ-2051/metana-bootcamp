// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Attack {
    Elevator private immutable target;

    constructor(address _target) {
        target = Elevator(_target);
    }

    function win() external {
        target.goTo(1);
        require(target.top() == true, "not top");
    }
}

interface Building {
    function isLastFloor(uint) external returns (bool);
}

contract Elevator {
    bool public top;
    uint public floor;

    function goTo(uint _floor) public {
        Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}
