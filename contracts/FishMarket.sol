// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract FishMarket is ReentrancyGuard {
    struct Listing {
        address seller;
        uint256 price;
        bool active;
    }

    struct SaleRecord {
        uint256 price;
        uint256 timestamp;
    }

    // nftContract → tokenId → last sale
    mapping(address => mapping(uint256 => SaleRecord)) public lastSale;

    // nftContract → tokenId → listing
    mapping(address => mapping(uint256 => Listing)) public listings;

    event ItemListed(address indexed nft, uint256 indexed tokenId, address seller, uint256 price);
    event ItemCanceled(address indexed nft, uint256 indexed tokenId);
    event ItemBought(address indexed nft, uint256 indexed tokenId, address buyer, uint256 price);
    event PriceUpdated(address indexed nft, uint256 indexed tokenId, uint256 newPrice);

    modifier isOwner(address nft, uint256 tokenId) {
        require(IERC721(nft).ownerOf(tokenId) == msg.sender, "Not owner");
        _;
    }

    modifier isListed(address nft, uint256 tokenId) {
        require(listings[nft][tokenId].active, "Not listed");
        _;
    }

    function listItem(address nft, uint256 tokenId, uint256 price)
        external
        isOwner(nft, tokenId)
    {
        require(price > 0, "Price must be > 0");
        require(
            IERC721(nft).getApproved(tokenId) == address(this),
            "Marketplace not approved"
        );

        listings[nft][tokenId] = Listing(msg.sender, price, true);

        emit ItemListed(nft, tokenId, msg.sender, price);
    }

    function cancelListing(address nft, uint256 tokenId)
        external
        isListed(nft, tokenId)
    {
        Listing memory list = listings[nft][tokenId];
        require(list.seller == msg.sender, "Not seller");

        delete listings[nft][tokenId];

        emit ItemCanceled(nft, tokenId);
    }

    function updatePrice(address nft, uint256 tokenId, uint256 newPrice)
        external
        isListed(nft, tokenId)
    {
        Listing storage list = listings[nft][tokenId];
        require(list.seller == msg.sender, "Not seller");
        require(newPrice > 0, "Invalid price");

        list.price = newPrice;

        emit PriceUpdated(nft, tokenId, newPrice);
    }

    function buyItem(address nft, uint256 tokenId)
        external
        payable
        nonReentrant
        isListed(nft, tokenId)
    {
        Listing memory list = listings[nft][tokenId];
        require(msg.value == list.price, "Incorrect price");

        // Pay seller
        (bool sent, ) = payable(list.seller).call{value: msg.value}("");
        require(sent, "Payment failed");

        // Transfer NFT
        IERC721(nft).safeTransferFrom(list.seller, msg.sender, tokenId);

        // Record sale
        lastSale[nft][tokenId] = SaleRecord(list.price, block.timestamp);

        // Clear listing
        delete listings[nft][tokenId];

        emit ItemBought(nft, tokenId, msg.sender, msg.value);
    }

    // Optional helper for UI
    function getListing(address nft, uint256 tokenId)
        external
        view
        returns (Listing memory)
    {
        return listings[nft][tokenId];
    }

    function getLastSale(address nft, uint256 tokenId) external view returns (uint256 price, uint256 timestamp) {
        SaleRecord memory s = lastSale[nft][tokenId];
        return (s.price, s.timestamp);
    }
}
