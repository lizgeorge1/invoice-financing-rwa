// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AgentRole} from "../roles/AgentRole.sol";
import {IIdentity} from "../interfaces/IIdentity.sol";
import {IIdentityRegistryStorage} from "../interfaces/IIdentityRegistryStorage.sol";

/// @title IdentityRegistryStorage
/// @notice PHASE 2. The raw wallet -> (identity, country) table.
/// @dev Why a separate contract? In this project every invoice gets its own
///      token. If each token had its own investor table, an investor would
///      need onboarding once per invoice. With shared storage they are
///      onboarded once and every token's registry reads the same rows.
contract IdentityRegistryStorage is IIdentityRegistryStorage, AgentRole {
    struct StoredIdentity {
        IIdentity identityContract;
        uint16 investorCountry; // ISO 3166-1 numeric, e.g. 356 = India
    }

    mapping(address wallet => StoredIdentity) internal _identities;
    address[] internal _identityRegistries;

    constructor(address initialOwner) AgentRole(initialOwner) {}

    /// @dev Called by a bound Identity Registry, which is an agent here.
    function addIdentityToStorage(address _userAddress, IIdentity _identity, uint16 _country) external onlyAgent {
        // TODO 2.4: reject zero addresses and a wallet that is already stored.
        revert("TODO 2.4: IdentityRegistryStorage.addIdentityToStorage");
    }

    function removeIdentityFromStorage(address _userAddress) external onlyAgent {
        revert("TODO 2.4: IdentityRegistryStorage.removeIdentityFromStorage");
    }

    function modifyStoredInvestorCountry(address _userAddress, uint16 _country) external onlyAgent {
        revert("TODO 2.4: IdentityRegistryStorage.modifyStoredInvestorCountry");
    }

    function modifyStoredIdentity(address _userAddress, IIdentity _identity) external onlyAgent {
        revert("TODO 2.4: IdentityRegistryStorage.modifyStoredIdentity");
    }

    /// @dev Binding makes the registry an agent of this storage.
    function bindIdentityRegistry(address _identityRegistry) external onlyOwner {
        // TODO 2.4: the official code caps this at 300 bound registries.
        revert("TODO 2.4: IdentityRegistryStorage.bindIdentityRegistry");
    }

    function unbindIdentityRegistry(address _identityRegistry) external onlyOwner {
        revert("TODO 2.4: IdentityRegistryStorage.unbindIdentityRegistry");
    }

    function linkedIdentityRegistries() external view returns (address[] memory) {
        revert("TODO 2.4: IdentityRegistryStorage.linkedIdentityRegistries");
    }

    function storedIdentity(address _userAddress) external view returns (IIdentity) {
        revert("TODO 2.4: IdentityRegistryStorage.storedIdentity");
    }

    function storedInvestorCountry(address _userAddress) external view returns (uint16) {
        revert("TODO 2.4: IdentityRegistryStorage.storedInvestorCountry");
    }
}
