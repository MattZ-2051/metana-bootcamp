// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MyNft is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;

    uint256 public constant TOTAL_SUPPLY = 10;

    constructor() ERC721("MyNFT", "MNT") {
        baseTokenURI = "https://gateway.pinata.cloud/ipfs/Qmb6BJT1bjo37BubRqc5uRoqRWd6u4cJREAeoaJAfZq1j3/";
    }

    string public baseTokenURI;

    function mintTo(address recipient) public returns (uint256) {
        uint256 tokenId = currentTokenId.current();
        require(tokenId < TOTAL_SUPPLY, "Max supply reached");
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    /// @dev Returns an URI for a given token ID
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    /**
     * Override isApprovedForAll to auto-approve OS's proxy contract
     */
    function isApprovedForAll(
        address _owner,
        address _operator
    ) public view override returns (bool isOperator) {
        // if OpenSea's ERC721 Proxy Address is detected, auto-return true
        if (_operator == address(0x58807baD0B376efc12F5AD86aAc70E78ed67deaE)) {
            return true;
        }

        // otherwise, use the default ERC721.isApprovedForAll()
        return ERC721.isApprovedForAll(_owner, _operator);
    }

    receive() external payable {}

    fallback() external payable {}
}

contract MyErc is ERC20 {
    address private owner = msg.sender;
    uint256 maxSupply = 100000000 * (10 ** 18);

    constructor(uint256 initialSupply) ERC20("test", "TST") {
        _mint(msg.sender, initialSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can withdraw");
        _;
    }

    function withdrawTokens() external onlyOwner {
        this.transfer(owner, balanceOf(address(this)));
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function createTokens() external payable {
        require(totalSupply() <= maxSupply, "max supply reached");
        _mint(msg.sender, 10 * (10 ** 18));
    }

    receive() external payable {}

    fallback() external payable {}
}

contract Stake is Ownable, ReentrancyGuard {
    MyErc public immutable Token;
    MyNft public immutable Nft;
    uint256 private immutable tokenRewardAmount = 10 * (10 ** 18);

    struct StakedNft {
        address owner;
        uint256 tokenId;
    }

    struct Staker {
        StakedNft[] stakedTokens;
        uint256 rewards;
        uint256 lastUpdateTime;
    }

    constructor(address payable _tokenAddress, address payable _nftAddress) {
        Token = MyErc(_tokenAddress);
        Nft = MyNft(_nftAddress);
    }
}
