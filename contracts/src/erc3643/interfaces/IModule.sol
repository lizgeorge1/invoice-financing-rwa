// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Compliance module
/// @notice One rule. `moduleCheck` is the read-only question; the three
///         `module*Action` hooks let a stateful rule keep its own counters.
/// @dev The official interface also has `canComplianceBind` and `isPlugAndPlay`.
interface IModule {
    event ComplianceBound(address indexed _compliance);
    event ComplianceUnbound(address indexed _compliance);

    function bindCompliance(address _compliance) external;
    function unbindCompliance(address _compliance) external;

    function moduleTransferAction(address _from, address _to, uint256 _value) external;
    function moduleMintAction(address _to, uint256 _value) external;
    function moduleBurnAction(address _from, uint256 _value) external;

    function moduleCheck(address _from, address _to, uint256 _value, address _compliance)
        external
        view
        returns (bool);
    function isComplianceBound(address _compliance) external view returns (bool);
    function name() external pure returns (string memory _name);
}
