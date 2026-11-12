// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IIdentity} from "./IIdentity.sol";

/// @title Identity Registry Storage
/// @notice The wallet -> (identity, country) table. Kept separate from the
///         Identity Registry so several tokens can share one investor list.
interface IIdentityRegistryStorage {
    event IdentityStored(address indexed investorAddress, IIdentity indexed identity);
    event IdentityUnstored(address indexed investorAddress, IIdentity indexed identity);
    event IdentityModified(IIdentity indexed oldIdentity, IIdentity indexed newIdentity);
    event CountryModified(address indexed investorAddress, uint16 indexed country);
    event IdentityRegistryBound(address indexed identityRegistry);
    event IdentityRegistryUnbound(address indexed identityRegistry);

    function addIdentityToStorage(address _userAddress, IIdentity _identity, uint16 _country) external;
    function removeIdentityFromStorage(address _userAddress) external;
    function modifyStoredInvestorCountry(address _userAddress, uint16 _country) external;
    function modifyStoredIdentity(address _userAddress, IIdentity _identity) external;
    function bindIdentityRegistry(address _identityRegistry) external;
    function unbindIdentityRegistry(address _identityRegistry) external;

    function linkedIdentityRegistries() external view returns (address[] memory);
    function storedIdentity(address _userAddress) external view returns (IIdentity);
    function storedInvestorCountry(address _userAddress) external view returns (uint16);
}
