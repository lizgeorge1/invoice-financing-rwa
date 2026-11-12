// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IIdentityRegistry} from "./IIdentityRegistry.sol";
import {IModularCompliance} from "./IModularCompliance.sol";

/// @title ERC-3643 token (T-REX `IToken`)
/// @notice A permissioned ERC-20: every holder must be verified, every transfer
///         must pass compliance, and agents can freeze, force and recover.
/// @dev The official interface also has `version()` and batch variants of
///      transfer, forcedTransfer, mint, burn and the freeze functions.
interface IToken is IERC20 {
    event UpdatedTokenInformation(
        string indexed _newName, string indexed _newSymbol, uint8 _newDecimals, address indexed _newOnchainID
    );
    event IdentityRegistryAdded(address indexed _identityRegistry);
    event ComplianceAdded(address indexed _compliance);
    event RecoverySuccess(address indexed _lostWallet, address indexed _newWallet, address indexed _investorOnchainID);
    event AddressFrozen(address indexed _userAddress, bool indexed _isFrozen, address indexed _owner);
    event TokensFrozen(address indexed _userAddress, uint256 _amount);
    event TokensUnfrozen(address indexed _userAddress, uint256 _amount);
    event Paused(address _userAddress);
    event Unpaused(address _userAddress);

    // Owner: configuration
    function setName(string calldata _name) external;
    function setSymbol(string calldata _symbol) external;
    function setOnchainID(address _onchainID) external;
    function setIdentityRegistry(address _identityRegistry) external;
    function setCompliance(address _compliance) external;

    // Agent: operations
    function pause() external;
    function unpause() external;
    function mint(address _to, uint256 _amount) external;
    function burn(address _userAddress, uint256 _amount) external;
    function setAddressFrozen(address _userAddress, bool _freeze) external;
    function freezePartialTokens(address _userAddress, uint256 _amount) external;
    function unfreezePartialTokens(address _userAddress, uint256 _amount) external;
    function forcedTransfer(address _from, address _to, uint256 _amount) external returns (bool);
    function recoveryAddress(address _lostWallet, address _newWallet, address _investorOnchainID)
        external
        returns (bool);

    // Views
    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function onchainID() external view returns (address);
    function identityRegistry() external view returns (IIdentityRegistry);
    function compliance() external view returns (IModularCompliance);
    function paused() external view returns (bool);
    function isFrozen(address _userAddress) external view returns (bool);
    function getFrozenTokens(address _userAddress) external view returns (uint256);
}
