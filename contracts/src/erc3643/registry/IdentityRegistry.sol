// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AgentRole} from "../roles/AgentRole.sol";
import {IIdentity} from "../interfaces/IIdentity.sol";
import {IClaimIssuer} from "../interfaces/IClaimIssuer.sol";
import {IClaimTopicsRegistry} from "../interfaces/IClaimTopicsRegistry.sol";
import {ITrustedIssuersRegistry} from "../interfaces/ITrustedIssuersRegistry.sol";
import {IIdentityRegistryStorage} from "../interfaces/IIdentityRegistryStorage.sol";
import {IIdentityRegistry} from "../interfaces/IIdentityRegistry.sol";

/// @title IdentityRegistry
/// @notice PHASE 2. The heart of ERC-3643 eligibility. It ties the three
///         other registries together and answers `isVerified(wallet)`.
contract IdentityRegistry is IIdentityRegistry, AgentRole {
    IClaimTopicsRegistry internal _tokenTopicsRegistry;
    ITrustedIssuersRegistry internal _tokenIssuersRegistry;
    IIdentityRegistryStorage internal _tokenIdentityStorage;

    constructor(
        address _trustedIssuersRegistry,
        address _claimTopicsRegistry,
        address _identityStorage,
        address initialOwner
    ) AgentRole(initialOwner) {
        // TODO 2.5: store the three registries and emit the three *Set events.
    }

    // ───────────────────── Agent: investor onboarding ────────────────────

    function registerIdentity(address _userAddress, IIdentity _identity, uint16 _country) external onlyAgent {
        // TODO 2.5: this contract holds no investor data. Where does it go?
        revert("TODO 2.5: IdentityRegistry.registerIdentity");
    }

    function deleteIdentity(address _userAddress) external onlyAgent {
        revert("TODO 2.5: IdentityRegistry.deleteIdentity");
    }

    function updateCountry(address _userAddress, uint16 _country) external onlyAgent {
        revert("TODO 2.5: IdentityRegistry.updateCountry");
    }

    function updateIdentity(address _userAddress, IIdentity _identity) external onlyAgent {
        revert("TODO 2.5: IdentityRegistry.updateIdentity");
    }

    // ───────────────────────── Owner: wiring ─────────────────────────────

    function setIdentityRegistryStorage(address _identityRegistryStorage) external onlyOwner {
        revert("TODO 2.5: IdentityRegistry.setIdentityRegistryStorage");
    }

    function setClaimTopicsRegistry(address _claimTopicsRegistry) external onlyOwner {
        revert("TODO 2.5: IdentityRegistry.setClaimTopicsRegistry");
    }

    function setTrustedIssuersRegistry(address _trustedIssuersRegistry) external onlyOwner {
        revert("TODO 2.5: IdentityRegistry.setTrustedIssuersRegistry");
    }

    // ────────────────────────────── Views ────────────────────────────────

    /// @notice May this wallet hold the token?
    function isVerified(address _userAddress) external view returns (bool) {
        // TODO 2.6: the most important function in the standard.
        //
        // In words:
        //   1. No identity registered for the wallet -> false.
        //   2. No required topics -> true.
        //   3. For EVERY required topic, the identity must hold a claim from
        //      AT LEAST ONE issuer trusted for that topic, and that issuer
        //      must confirm the claim is valid right now.
        //
        // Things to work out:
        // - You do not need to scan the identity's claims. Given an issuer
        //   and a topic you can compute the claim id directly (step 1.2).
        // - A required topic with no trusted issuer at all: true or false?
        // - `isClaimValid` is a call into a contract someone else deployed.
        //   What should happen to this function if that call reverts?
        //   Look up `try/catch` for external calls.
        // - This runs on every transfer. What is its cost in terms of
        //   (number of topics) x (issuers per topic)?
        revert("TODO 2.6: IdentityRegistry.isVerified");
    }

    function contains(address _userAddress) external view returns (bool) {
        revert("TODO 2.5: IdentityRegistry.contains");
    }

    function identity(address _userAddress) public view returns (IIdentity) {
        revert("TODO 2.5: IdentityRegistry.identity");
    }

    function investorCountry(address _userAddress) external view returns (uint16) {
        revert("TODO 2.5: IdentityRegistry.investorCountry");
    }

    function identityStorage() external view returns (IIdentityRegistryStorage) {
        revert("TODO 2.5: IdentityRegistry.identityStorage");
    }

    function issuersRegistry() external view returns (ITrustedIssuersRegistry) {
        revert("TODO 2.5: IdentityRegistry.issuersRegistry");
    }

    function topicsRegistry() external view returns (IClaimTopicsRegistry) {
        revert("TODO 2.5: IdentityRegistry.topicsRegistry");
    }
}
