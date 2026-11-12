// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IIdentity} from "./IIdentity.sol";

/// @title Claim issuer
/// @notice The on-chain face of a KYC provider. It is itself an identity whose
///         CLAIM keys sign claims off-chain, and it can revoke them.
/// @dev The official interface also has `revokeClaim(claimId, identity)`.
interface IClaimIssuer is IIdentity {
    event ClaimRevoked(bytes indexed signature);

    function revokeClaimBySignature(bytes calldata signature) external;
    function isClaimRevoked(bytes calldata _sig) external view returns (bool);
    function isClaimValid(IIdentity _identity, uint256 claimTopic, bytes calldata sig, bytes calldata data)
        external
        view
        returns (bool);
}
