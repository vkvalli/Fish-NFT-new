// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IFishNFT {
    function ownerOf(uint256 tokenId) external view returns (address);
    function tokenCounter() external view returns (uint256);
}

contract RewardClaim {
    IFishNFT public fishNFT;
    
    // Reward amount per NFT (in wei)
    uint256 public rewardPerNFT;
    
    // Mapping to track which NFTs have claimed rewards
    mapping(uint256 => bool) public hasClaimed;
    
    // Mapping to track total rewards claimed by user
    mapping(address => uint256) public totalClaimed;
    
    // Tracking for reward statistics
    uint256 public totalRewardsPaid;
    uint256 public totalClaimEvents;
    
    // Contract owner
    address public owner;
    
    // Events
    event RewardClaimed(address indexed user, uint256 indexed tokenId, uint256 amount, uint256 timestamp);
    event RewardAmountUpdated(uint256 newAmount);
    event FundsDeposited(address indexed from, uint256 amount);
    event FundsWithdrawn(address indexed to, uint256 amount);
    
    constructor(address _fishNFTAddress, uint256 _rewardPerNFT) {
        fishNFT = IFishNFT(_fishNFTAddress);
        rewardPerNFT = _rewardPerNFT;
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }
    
    // Allow contract to receive funds
    receive() external payable {
        emit FundsDeposited(msg.sender, msg.value);
    }
    
    // Fallback function
    fallback() external payable {
        emit FundsDeposited(msg.sender, msg.value);
    }
    
    // Claim reward for a specific NFT
    function claimReward(uint256 tokenId) external {
        require(fishNFT.ownerOf(tokenId) == msg.sender, "You don't own this NFT");
        require(!hasClaimed[tokenId], "Reward already claimed for this NFT");
        require(address(this).balance >= rewardPerNFT, "Insufficient contract balance");
        
        hasClaimed[tokenId] = true;
        totalClaimed[msg.sender] += rewardPerNFT;
        totalRewardsPaid += rewardPerNFT;
        totalClaimEvents++;
        
        (bool success, ) = payable(msg.sender).call{value: rewardPerNFT}("");
        require(success, "Transfer failed");
        
        emit RewardClaimed(msg.sender, tokenId, rewardPerNFT, block.timestamp);
    }
    
    // Claim rewards for multiple NFTs at once
    function claimMultipleRewards(uint256[] calldata tokenIds) external {
        require(tokenIds.length > 0, "No token IDs provided");
        uint256 totalReward = 0;
        
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            
            require(fishNFT.ownerOf(tokenId) == msg.sender, "You don't own all NFTs");
            require(!hasClaimed[tokenId], "One or more NFTs already claimed");
            
            hasClaimed[tokenId] = true;
            totalReward += rewardPerNFT;
        }
        
        require(address(this).balance >= totalReward, "Insufficient contract balance");
        
        totalClaimed[msg.sender] += totalReward;
        totalRewardsPaid += totalReward;
        totalClaimEvents += tokenIds.length;
        
        (bool success, ) = payable(msg.sender).call{value: totalReward}("");
        require(success, "Transfer failed");
        
        for (uint256 i = 0; i < tokenIds.length; i++) {
            emit RewardClaimed(msg.sender, tokenIds[i], rewardPerNFT, block.timestamp);
        }
    }
    
    // Check if reward is claimable for a token
    function isClaimable(uint256 tokenId, address user) external view returns (bool) {
        try fishNFT.ownerOf(tokenId) returns (address tokenOwner) {
            if (hasClaimed[tokenId]) return false;
            if (tokenOwner != user) return false;
            if (address(this).balance < rewardPerNFT) return false;
            return true;
        } catch {
            return false;
        }
    }
    
    // Get claim status for multiple tokens
    function getClaimStatuses(uint256[] calldata tokenIds) external view returns (bool[] memory) {
        bool[] memory statuses = new bool[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            statuses[i] = hasClaimed[tokenIds[i]];
        }
        return statuses;
    }
    
    // Owner functions
    function updateRewardAmount(uint256 _newAmount) external onlyOwner {
        rewardPerNFT = _newAmount;
        emit RewardAmountUpdated(_newAmount);
    }
    
    function depositFunds() external payable onlyOwner {
        require(msg.value > 0, "Must send ETH");
        emit FundsDeposited(msg.sender, msg.value);
    }
    
    function withdrawFunds(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Withdrawal failed");
        emit FundsWithdrawn(owner, amount);
    }
    
    function emergencyWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Emergency withdrawal failed");
        emit FundsWithdrawn(owner, balance);
    }
    
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    // Get reward statistics
    function getRewardStats() external view returns (
        uint256 contractBalance,
        uint256 totalPaid,
        uint256 totalClaims,
        uint256 rewardAmount
    ) {
        return (
            address(this).balance,
            totalRewardsPaid,
            totalClaimEvents,
            rewardPerNFT
        );
    }
    
    // Transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        owner = newOwner;
    }
}