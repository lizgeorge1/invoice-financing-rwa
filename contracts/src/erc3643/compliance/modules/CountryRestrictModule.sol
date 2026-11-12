// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AbstractModule} from "./AbstractModule.sol";

/// @title CountryRestrictModule
/// @notice PHASE 5. A stateless rule: wallets registered in a restricted
///         country cannot receive the token.
/// @dev Deviation from T-REX: there, module settings are changed through
///      `ModularCompliance.callModuleFunction`, so msg.sender is the
///      compliance. Here the compliance's owner calls the module directly.
///      Implementing `callModuleFunction` is a stretch goal in the path.
contract CountryRestrictModule is AbstractModule {
    mapping(address compliance => mapping(uint16 country => bool)) internal _restrictedCountries;

    event AddedRestrictedCountry(address indexed _compliance, uint16 _country);
    event RemovedRestrictedCountry(address indexed _compliance, uint16 _country);

    /// @dev Only the owner of `_compliance` may call.
    function addCountryRestriction(address _compliance, uint16 _country) external {
        revert("TODO 5.2: CountryRestrictModule.addCountryRestriction");
    }

    /// @dev Only the owner of `_compliance` may call.
    function removeCountryRestriction(address _compliance, uint16 _country) external {
        revert("TODO 5.2: CountryRestrictModule.removeCountryRestriction");
    }

    function isCountryRestricted(address _compliance, uint16 _country) public view returns (bool) {
        revert("TODO 5.2: CountryRestrictModule.isCountryRestricted");
    }

    function moduleCheck(address _from, address _to, uint256 _value, address _compliance)
        external
        view
        returns (bool)
    {
        // TODO 5.2
        // - The module only receives wallet addresses. Find the path from
        //   `_compliance` to the receiver's country:
        //   compliance -> token -> identity registry -> investorCountry.
        // - Burns arrive with _to == address(0). What should they return?
        revert("TODO 5.2: CountryRestrictModule.moduleCheck");
    }

    // A stateless module has nothing to record. Decide what these three
    // should do (and who may call them) in TODO 5.2.
    function moduleTransferAction(address _from, address _to, uint256 _value) external {
        revert("TODO 5.2: CountryRestrictModule.moduleTransferAction");
    }

    function moduleMintAction(address _to, uint256 _value) external {
        revert("TODO 5.2: CountryRestrictModule.moduleMintAction");
    }

    function moduleBurnAction(address _from, uint256 _value) external {
        revert("TODO 5.2: CountryRestrictModule.moduleBurnAction");
    }

    function name() external pure returns (string memory _name) {
        return "CountryRestrictModule";
    }
}
