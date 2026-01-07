// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract CreatorBoost {
    IERC721 public nftContract;

    struct Fish {
        uint256 boostCount; 
        uint256 pendingBoostShare; 
        uint256 bonusClaimed; 
    }

    mapping(uint256 => Fish) public fishes;

    uint256 public bonusPool; // bonusPool balance
    uint256 public constant boostAmount = 0.05 ether; // fixed boost amount
    uint256 public constant boostsPerBonus = 3; // every 3 boost can claim bonus

    constructor(address _nftAddress) {
        nftContract = IERC721(_nftAddress);
    }

    // -------------------- Gallery: Boost NFT --------------------
    function boostFish(uint256 tokenId) external payable {
        require(msg.value == boostAmount, "Send exact boost amount");
        require(nftContract.ownerOf(tokenId) != msg.sender, "Cannot Boost own NFT");

        fishes[tokenId].boostCount += 1;

        // divided boost fee into half
        uint256 half = msg.value / 2;
        bonusPool += half; // half boost fee goes into public bonus pool for bonus
        fishes[tokenId].pendingBoostShare += msg.value - half; // half goes into NFT's pending boost earnings
    }

    // -------------------- MyGallery: claim boost share --------------------
    function claimBoostShare(uint256 tokenId) external {
        require(nftContract.ownerOf(tokenId) == msg.sender, "Not NFT owner");
        require(fishes[tokenId].pendingBoostShare > 0, "No pending Boost Share to claim");

        uint256 pending = fishes[tokenId].pendingBoostShare;

        // rest pendingBoostShare
        fishes[tokenId].pendingBoostShare = 0;

        // pay the Boost share to the user
        payable(msg.sender).transfer(pending);
    }

    // -------------------- MyGallery: claim bonus --------------------
    function claimBonus(uint256 tokenId) external {
        require(nftContract.ownerOf(tokenId) == msg.sender, "Not NFT owner");
        require(fishes[tokenId].boostCount >= boostsPerBonus, "Not enough boosts for bonus");
        require(bonusPool > 0, "Bonus pool is empty");

        // caculate the number of claimable bonus 
        uint256 claimableBonuses = fishes[tokenId].boostCount / boostsPerBonus;

        // ramdom Bonus ：1~10% of bonusPool
        uint256 randomBonus = (bonusPool * (uint256(keccak256(abi.encodePacked(block.timestamp, tokenId))) % 10 + 1)) / 100;

        // update bonusPool
        require(randomBonus <= bonusPool, "Not enough in bonus pool");
        bonusPool -= randomBonus;

        // update NFT bonus cnt
        fishes[tokenId].boostCount -= claimableBonuses * boostsPerBonus;

        // pay bonus to the user
        payable(msg.sender).transfer(randomBonus);
    }
}
