// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title FishMetadata
 * @notice Stores off-chain-like metadata/traits on-chain for each NFT tokenId.
 * Minimal API: setTrait(tokenId, trait) and getTrait(tokenId).
 * Additional fields are provided to support ranking/interaction systems.
 */
contract FishMetadata {
    IERC721 public immutable nft;

    struct Meta {
        string name;          // art name/title
        string trait;         // primary trait/label
        uint256 likes;        // like count
        uint256 createdAt;    // unix timestamp
        address creator;      // original creator/artist
    }

    mapping(uint256 => Meta) private _metaByTokenId;

    modifier onlyTokenOwner(uint256 tokenId) {
        require(nft.ownerOf(tokenId) == msg.sender, "FishMetadata: caller is not token owner");
        _;
    }

    constructor(address nftAddress) {
        require(nftAddress != address(0), "FishMetadata: nft is zero");
        nft = IERC721(nftAddress);
    }

    // -------- Minimal API --------
    function setTrait(uint256 tokenId, string calldata trait) external onlyTokenOwner(tokenId) {
        _metaByTokenId[tokenId].trait = trait;
    }

    function getTrait(uint256 tokenId) external view returns (string memory) {
        return _metaByTokenId[tokenId].trait;
    }

    // -------- Extended metadata setters (owner-restricted) --------
    function setName(uint256 tokenId, string calldata name_) external onlyTokenOwner(tokenId) {
        _metaByTokenId[tokenId].name = name_;
    }

    function setCreator(uint256 tokenId, address creator_) external onlyTokenOwner(tokenId) {
        _metaByTokenId[tokenId].creator = creator_;
    }

    function setCreatedAt(uint256 tokenId, uint256 createdAt_) external onlyTokenOwner(tokenId) {
        _metaByTokenId[tokenId].createdAt = createdAt_;
    }

    /**
     * @notice Initialize or update primary metadata in ONE transaction.
     * - Sets name and trait.
     * - Sets creator to msg.sender.
     * - Sets createdAt to current block time ONLY if it has not been set before.
     */
    function initMetadata(uint256 tokenId, string calldata name_, string calldata trait_) external onlyTokenOwner(tokenId) {
        Meta storage m = _metaByTokenId[tokenId];
        m.name = name_;
        m.trait = trait_;
        if (m.createdAt == 0) {
            m.createdAt = block.timestamp;
        }
        m.creator = msg.sender;
    }

    // -------- Interaction counters (open incrementers) --------
    // Consider gating these in future (e.g., signatures or allowlist) to prevent spam.
    function incrementLike(uint256 tokenId) external {
        require(nft.ownerOf(tokenId) != msg.sender, "Cannot like own NFT");
        _metaByTokenId[tokenId].likes += 1;
    }

    // -------- View helpers --------
    function getMetadata(uint256 tokenId) external view returns (
        string memory name_,
        string memory trait_,
        uint256 likes_,
        uint256 createdAt_,
        address creator_
    ) {
        Meta storage m = _metaByTokenId[tokenId];
        return (
            m.name,
            m.trait,
            m.likes,
            m.createdAt,
            m.creator
        );
    }
}


