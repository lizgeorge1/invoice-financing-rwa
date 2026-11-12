// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Modular Compliance
/// @notice The rule engine bound to one token. It asks every module whether a
///         transfer is allowed, and tells every module after balances change.
/// @dev The official interface also has `callModuleFunction`, which lets the
///      owner configure a module through the compliance contract.
interface IModularCompliance {
    event TokenBound(address _token);
    event TokenUnbound(address _token);
    event ModuleAdded(address indexed _module);
    event ModuleRemoved(address indexed _module);

    function bindToken(address _token) external;
    function unbindToken(address _token) external;
    function addModule(address _module) external;
    function removeModule(address _module) external;

    function transferred(address _from, address _to, uint256 _amount) external;
    function created(address _to, uint256 _amount) external;
    function destroyed(address _from, uint256 _amount) external;

    function canTransfer(address _from, address _to, uint256 _amount) external view returns (bool);
    function getModules() external view returns (address[] memory);
    function getTokenBound() external view returns (address);
    function isModuleBound(address _module) external view returns (bool);
}
