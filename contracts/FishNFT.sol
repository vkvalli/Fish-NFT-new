// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract FishNFT is ERC721URIStorage {
    uint256 public tokenCounter;

    mapping(uint256 => uint256) public tokenCreatedAt;

    constructor() ERC721("FishNFT", "FISH") {
        tokenCounter = 0;
    }

    // allow all the user to mint
    function mint(string memory tokenURI) external returns (uint256) {
        uint256 newTokenId = tokenCounter;
        _safeMint(msg.sender, newTokenId);  
        _setTokenURI(newTokenId, tokenURI);
        tokenCreatedAt[newTokenId] = block.timestamp;
        tokenCounter += 1;
        return newTokenId;
    }

    // Minimal gift function
    function gift(uint256 tokenId, address to) external {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner");
        safeTransferFrom(msg.sender, to, tokenId);
    }

    // Allow owner burn NFT
    function burnNFT(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner");
        _burn(tokenId);
        delete tokenCreatedAt[tokenId]; 
    }
}
