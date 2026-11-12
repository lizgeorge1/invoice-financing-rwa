// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Claim Topics Registry
/// @notice The list of claim topics a holder of this token must have.
interface IClaimTopicsRegistry {
    event ClaimTopicAdded(uint256 indexed claimTopic);
    event ClaimTopicRemoved(uint256 indexed claimTopic);

    function addClaimTopic(uint256 _claimTopic) external;
    function removeClaimTopic(uint256 _claimTopic) external;
    function getClaimTopics() external view returns (uint256[] memory);
}
