// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Identity} from "./Identity.sol";
import {IIdentity} from "../interfaces/IIdentity.sol";
import {IClaimIssuer} from "../interfaces/IClaimIssuer.sol";

/// @title ClaimIssuer
/// @notice PHASE 1. The KYC provider's contract. Its CLAIM keys sign claims
///         off-chain; this contract lets anyone check a signature on-chain and
///         lets the provider revoke one.
/// @dev This is where the "fake KYC" lives. The provider is mocked, but the
///      claim format, signature and validation are the real mechanism.
contract ClaimIssuer is IClaimIssuer, Identity {
    mapping(bytes signature => bool) public revokedClaims;

    constructor(address initialManagementKey) Identity(initialManagementKey) {}

    /// @notice Is `sig` a live signature, by one of this issuer's CLAIM keys,
    ///         over (identity, topic, data)?
    function isClaimValid(IIdentity _identity, uint256 claimTopic, bytes calldata sig, bytes calldata data)
        external
        view
        returns (bool)
    {
        // TODO 1.3
        // The signed message in ONCHAINID is:
        //   dataHash = keccak256(abi.encode(_identity, claimTopic, data))
        //   digest   = EIP-191 "Ethereum Signed Message" prefix over dataHash
        //
        // - Why is the *identity address* inside the hash? What attack does
        //   that stop?
        // - Recover the signer, turn it into a key, check it has the CLAIM
        //   purpose on this issuer, and check the signature is not revoked.
        // - OpenZeppelin's ECDSA and MessageHashUtils are available.
        // - Return false for a bad signature rather than reverting, so the
        //   registry can move on to the next trusted issuer.
        revert("TODO 1.3: ClaimIssuer.isClaimValid");
    }

    /// @dev Only a MANAGEMENT key of the issuer may call.
    function revokeClaimBySignature(bytes calldata signature) external {
        // TODO 1.4
        // - Revocation lives on the issuer, not on the investor's identity.
        //   Why does that matter for an investor who refuses to remove a claim?
        revert("TODO 1.4: ClaimIssuer.revokeClaimBySignature");
    }

    function isClaimRevoked(bytes calldata _sig) public view returns (bool) {
        revert("TODO 1.4: ClaimIssuer.isClaimRevoked");
    }
}
