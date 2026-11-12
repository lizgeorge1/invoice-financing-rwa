// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IIdentity} from "./IIdentity.sol";
import {IClaimTopicsRegistry} from "./IClaimTopicsRegistry.sol";
import {ITrustedIssuersRegistry} from "./ITrustedIssuersRegistry.sol";
import {IIdentityRegistryStorage} from "./IIdentityRegistryStorage.sol";

/// @title Identity Registry
/// @notice Answers the one question the token asks: `isVerified(wallet)`.
/// @dev The official interface also has `batchRegisterIdentity`.
interface IIdentityRegistry {
    event ClaimTopicsRegistrySet(address indexed claimTopicsRegistry);
    event IdentityStorageSet(address indexed identityStorage);
    event TrustedIssuersRegistrySet(address indexed trustedIssuersRegistry);
    event IdentityRegistered(address indexed investorAddress, IIdentity indexed identity);
    event IdentityRemoved(address indexed investorAddress, IIdentity indexed identity);
    event IdentityUpdated(IIdentity indexed oldIdentity, IIdentity indexed newIdentity);
    event CountryUpdated(address indexed investorAddress, uint16 indexed country);

    function registerIdentity(address _userAddress, IIdentity _identity, uint16 _country) external;
    function deleteIdentity(address _userAddress) external;
    function updateCountry(address _userAddress, uint16 _country) external;
    function updateIdentity(address _userAddress, IIdentity _identity) external;
    function setIdentityRegistryStorage(address _identityRegistryStorage) external;
    function setClaimTopicsRegistry(address _claimTopicsRegistry) external;
    function setTrustedIssuersRegistry(address _trustedIssuersRegistry) external;

    function contains(address _userAddress) external view returns (bool);
    function isVerified(address _userAddress) external view returns (bool);
    function identity(address _userAddress) external view returns (IIdentity);
    function investorCountry(address _userAddress) external view returns (uint16);
    function identityStorage() external view returns (IIdentityRegistryStorage);
    function issuersRegistry() external view returns (ITrustedIssuersRegistry);
    function topicsRegistry() external view returns (IClaimTopicsRegistry);
}
