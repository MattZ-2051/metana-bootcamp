// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PartialRefund is ERC20 {
    address private owner = msg.sender;
    uint256 maxSupply = 100000000 * (10 ** 18);

    constructor(uint256 initialSupply) ERC20("test", "TST") {
        _mint(msg.sender, initialSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can withdraw");
        _;
    }

    function withdrawEth() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function withdrawTokens() external onlyOwner {
        this.transfer(owner, balanceOf(address(this)));
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function createTokens() external payable {
        require(msg.value >= 1 ether, "Must send at least 1 ETH");
        require(totalSupply() <= maxSupply, "max supply reached");
        _mint(msg.sender, 1000 * (10 ** 18));
    }

    function sellBack(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Not enough tokens");
        if (amount >= 1000 * (10 ** 18)) {
            uint256 amountEth = amount / 1000 ether;
            uint256 ethToTransfer = amountEth * 500000000000000000;
            require(
                address(this).balance >= ethToTransfer,
                "Not enough eth in contract sell 1000 less tokens"
            );
            payable(msg.sender).transfer(ethToTransfer);
        }
        transferFrom(msg.sender, address(this), amount);
    }

    receive() external payable {}

    fallback() external payable {}
}
