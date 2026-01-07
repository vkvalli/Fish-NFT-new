// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Vote {
    mapping(uint256 => uint256) private _votes;
    // Track total votes per user per token 
    mapping(address => mapping(uint256 => uint256)) private _userVotesForToken;
    uint256 public constant MAX_VOTES_PER_TOKEN = 3;

    event Voted(uint256 indexed tokenId, address indexed voter, uint256 newCount);

    function count(uint256 tokenId) external {
        require(
            _userVotesForToken[msg.sender][tokenId] < MAX_VOTES_PER_TOKEN,
            "Vote limit reached"
        );

        _votes[tokenId] += 1;
        _userVotesForToken[msg.sender][tokenId] += 1;

        emit Voted(tokenId, msg.sender, _votes[tokenId]);
    }

    function getVotes(uint256 tokenId) external view returns (uint256) {
        return _votes[tokenId];
    }

    function getRemainingVotes(uint256 tokenId) external view returns (uint256) {
        uint256 used = _userVotesForToken[msg.sender][tokenId];
        if (used >= MAX_VOTES_PER_TOKEN) return 0;
        return MAX_VOTES_PER_TOKEN - used;
    }
}
