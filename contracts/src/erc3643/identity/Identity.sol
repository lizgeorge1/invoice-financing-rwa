// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IIdentity} from "../interfaces/IIdentity.sol";

/// @title Identity (ONCHAINID, simplified)
/// @notice PHASE 1. One of these is deployed per investor. It answers two
///         questions: "which keys may act for this person?" (ERC-734) and
///         "what has been attested about this person?" (ERC-735).
contract Identity is IIdentity {
    uint256 public constant MANAGEMENT_KEY = 1;
    uint256 public constant ACTION_KEY = 2;
    uint256 public constant CLAIM_SIGNER_KEY = 3;
    uint256 public constant ECDSA_TYPE = 1;

    struct Key {
        uint256[] purposes;
        uint256 keyType;
        bytes32 key;
    }

    struct Claim {
        uint256 topic;
        uint256 scheme;
        address issuer;
        bytes signature;
        bytes data;
        string uri;
    }

    mapping(bytes32 key => Key) internal _keys;
    mapping(bytes32 claimId => Claim) internal _claims;
    mapping(uint256 topic => bytes32[] claimIds) internal _claimsByTopic;

    /// @param initialManagementKey The wallet that controls this identity.
    constructor(address initialManagementKey) {
        // TODO 1.1: register keccak256(abi.encode(initialManagementKey)) as a
        // MANAGEMENT key so the identity is not born without an owner.
    }

    // ─────────────────────────── ERC-734: keys ───────────────────────────

    /// @dev Only a MANAGEMENT key may call. A key can hold several purposes.
    function addKey(bytes32 _key, uint256 _purpose, uint256 _keyType) external returns (bool success) {
        // TODO 1.1
        // - Who is the caller, expressed as a key? How do you check their purpose?
        // - What if the key already has this purpose?
        revert("TODO 1.1: Identity.addKey");
    }

    /// @dev Only a MANAGEMENT key may call.
    function removeKey(bytes32 _key, uint256 _purpose) external returns (bool success) {
        // TODO 1.1
        // - Removing an element from `purposes` without leaving a gap.
        // - Should the last MANAGEMENT key be removable? What happens if it is?
        revert("TODO 1.1: Identity.removeKey");
    }

    function getKeyPurposes(bytes32 _key) external view returns (uint256[] memory _purposes) {
        revert("TODO 1.1: Identity.getKeyPurposes");
    }

    function keyHasPurpose(bytes32 _key, uint256 _purpose) public view returns (bool exists) {
        // TODO 1.1
        // - In the official implementation a MANAGEMENT key passes every
        //   purpose check. Decide whether yours does, and note the consequence
        //   for ClaimIssuer.isClaimValid.
        revert("TODO 1.1: Identity.keyHasPurpose");
    }

    // ────────────────────────── ERC-735: claims ──────────────────────────

    /// @notice Store a claim an issuer has signed about this identity.
    /// @dev Only a MANAGEMENT or CLAIM_SIGNER key of *this identity* may call:
    ///      the investor decides which claims they carry.
    function addClaim(
        uint256 _topic,
        uint256 _scheme,
        address issuer,
        bytes calldata _signature,
        bytes calldata _data,
        string calldata _uri
    ) external returns (bytes32 claimRequestId) {
        // TODO 1.2
        // - claimId = keccak256(abi.encode(issuer, _topic)). Why does that make
        //   "one claim per issuer per topic" true by construction?
        // - New claim -> ClaimAdded and index it under its topic.
        //   Existing id -> overwrite and emit ClaimChanged.
        // - The official code asks the issuer contract whether the claim is
        //   valid before storing it. Is that check needed here, given that
        //   IdentityRegistry.isVerified validates again at read time?
        revert("TODO 1.2: Identity.addClaim");
    }

    function removeClaim(bytes32 _claimId) external returns (bool success) {
        // TODO 1.2: also remove the id from `_claimsByTopic`.
        revert("TODO 1.2: Identity.removeClaim");
    }

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
        )
    {
        // TODO 1.2: a missing claim returns zero values, it does not revert.
        // IdentityRegistry.isVerified relies on that.
        revert("TODO 1.2: Identity.getClaim");
    }

    function getClaimIdsByTopic(uint256 _topic) external view returns (bytes32[] memory claimIds) {
        revert("TODO 1.2: Identity.getClaimIdsByTopic");
    }
}
