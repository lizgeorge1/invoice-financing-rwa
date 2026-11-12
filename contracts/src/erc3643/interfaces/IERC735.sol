// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ERC-735 Claim Holder
/// @notice Claims about an identity, each signed by a claim issuer.
/// @dev A claim id is `keccak256(abi.encode(issuer, topic))`, so an identity
///      holds at most one claim per (issuer, topic) pair.
interface IERC735 {
    event ClaimAdded(
        bytes32 indexed claimId,
        uint256 indexed topic,
        uint256 scheme,
        address indexed issuer,
        bytes signature,
        bytes data,
        string uri
    );
    event ClaimRemoved(
        bytes32 indexed claimId,
        uint256 indexed topic,
        uint256 scheme,
        address indexed issuer,
        bytes signature,
        bytes data,
        string uri
    );
    event ClaimChanged(
        bytes32 indexed claimId,
        uint256 indexed topic,
        uint256 scheme,
        address indexed issuer,
        bytes signature,
        bytes data,
        string uri
    );

    function addClaim(
        uint256 _topic,
        uint256 _scheme,
        address issuer,
        bytes calldata _signature,
        bytes calldata _data,
        string calldata _uri
    ) external returns (bytes32 claimRequestId);

    function removeClaim(bytes32 _claimId) external returns (bool success);

    function getClaim(bytes32 _claimId)
        external
        view
        returns (
            uint256 topic,
            uint256 scheme,
            address issuer,
            bytes memory signature,
            bytes memory data,
            string memory uri
        );

    function getClaimIdsByTopic(uint256 _topic) external view returns (bytes32[] memory claimIds);
}
