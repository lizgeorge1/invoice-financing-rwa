// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IModule} from "../../interfaces/IModule.sol";

/// @title AbstractModule
/// @notice PHASE 5. Shared plumbing for compliance modules. One deployed
///         module can serve many compliance contracts, so all module state
///         is keyed by the compliance address.
abstract contract AbstractModule is IModule {
    mapping(address compliance => bool) internal _complianceBound;

    /// @dev The caller is a compliance contract this module is bound to.
    modifier onlyComplianceCall() {
        // TODO 5.1: replace this revert with the real check.
        revert("TODO 5.1: AbstractModule.onlyComplianceCall");
        _;
    }

    function bindCompliance(address _compliance) external {
        // TODO 5.1
        // - A compliance binds *itself* (msg.sender == _compliance). Why must
        //   nobody be able to bind a compliance on its behalf?
        revert("TODO 5.1: AbstractModule.bindCompliance");
    }

    function unbindCompliance(address _compliance) external {
        revert("TODO 5.1: AbstractModule.unbindCompliance");
    }

    function isComplianceBound(address _compliance) external view returns (bool) {
        revert("TODO 5.1: AbstractModule.isComplianceBound");
    }
}
