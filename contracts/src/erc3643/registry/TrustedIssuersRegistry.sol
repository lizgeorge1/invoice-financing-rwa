// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IClaimIssuer} from "../interfaces/IClaimIssuer.sol";
import {ITrustedIssuersRegistry} from "../interfaces/ITrustedIssuersRegistry.sol";

/// @title TrustedIssuersRegistry
/// @notice PHASE 2. "We accept claims from these issuers, each only for these
///         topics." An issuer trusted for KYC is not automatically trusted
///         for accreditation.
contract TrustedIssuersRegistry is ITrustedIssuersRegistry, Ownable {
    IClaimIssuer[] internal _trustedIssuers;
    mapping(address issuer => uint256[] topics) internal _trustedIssuerClaimTopics;
    mapping(uint256 topic => IClaimIssuer[] issuers) internal _claimTopicsToTrustedIssuers;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function addTrustedIssuer(IClaimIssuer _trustedIssuer, uint256[] calldata _claimTopics) external onlyOwner {
        // TODO 2.3
        // - Two indexes describe the same fact (issuer -> topics and
        //   topic -> issuers). Every write must keep both in step.
        // - Reject a zero address, an issuer that is already trusted, and an
        //   empty topic list.
        revert("TODO 2.3: TrustedIssuersRegistry.addTrustedIssuer");
    }

    function removeTrustedIssuer(IClaimIssuer _trustedIssuer) external onlyOwner {
        // TODO 2.3: every investor holding only this issuer's claims stops
        // being verified the moment this succeeds. No token is touched.
        revert("TODO 2.3: TrustedIssuersRegistry.removeTrustedIssuer");
    }

    function updateIssuerClaimTopics(IClaimIssuer _trustedIssuer, uint256[] calldata _claimTopics)
        external
        onlyOwner
    {
        revert("TODO 2.3: TrustedIssuersRegistry.updateIssuerClaimTopics");
    }

    function getTrustedIssuers() external view returns (IClaimIssuer[] memory) {
        revert("TODO 2.3: TrustedIssuersRegistry.getTrustedIssuers");
    }

    function getTrustedIssuersForClaimTopic(uint256 claimTopic) external view returns (IClaimIssuer[] memory) {
        revert("TODO 2.3: TrustedIssuersRegistry.getTrustedIssuersForClaimTopic");
    }

    function isTrustedIssuer(address _issuer) external view returns (bool) {
        revert("TODO 2.3: TrustedIssuersRegistry.isTrustedIssuer");
    }

    function getTrustedIssuerClaimTopics(IClaimIssuer _trustedIssuer) external view returns (uint256[] memory) {
        revert("TODO 2.3: TrustedIssuersRegistry.getTrustedIssuerClaimTopics");
    }

    function hasClaimTopic(address _issuer, uint256 _claimTopic) external view returns (bool) {
        revert("TODO 2.3: TrustedIssuersRegistry.hasClaimTopic");
    }
}
