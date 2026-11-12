// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IModularCompliance} from "../interfaces/IModularCompliance.sol";
import {IModule} from "../interfaces/IModule.sol";

/// @title ModularCompliance
/// @notice PHASE 3. Identity answers "WHO may hold the token". Compliance
///         answers "is THIS transfer allowed by the offering's rules"
///         (country bans, holder caps, lock-ups). The rules themselves live
///         in pluggable modules; this contract only fans calls out to them.
contract ModularCompliance is IModularCompliance, Ownable {
    address internal _tokenBound;
    address[] internal _modules;
    mapping(address module => bool) internal _moduleBound;

    constructor(address initialOwner) Ownable(initialOwner) {}

    modifier onlyToken() {
        // TODO 3.1: replace this revert with the real check.
        revert("TODO 3.1: ModularCompliance.onlyToken");
        _;
    }

    // ─────────────────────────── Token binding ───────────────────────────

    function bindToken(address _token) external {
        // TODO 3.1
        // - Who may call? In the official code: the owner, or the token
        //   itself when no token is bound yet (Token.setCompliance calls
        //   this). Why is the second path needed?
        revert("TODO 3.1: ModularCompliance.bindToken");
    }

    function unbindToken(address _token) external {
        revert("TODO 3.1: ModularCompliance.unbindToken");
    }

    // ───────────────────────── Module management ─────────────────────────

    function addModule(address _module) external onlyOwner {
        // TODO 3.2
        // - Reject zero address and duplicates; the official cap is 25.
        // - The module must be told it now serves this compliance
        //   (IModule.bindCompliance).
        revert("TODO 3.2: ModularCompliance.addModule");
    }

    function removeModule(address _module) external onlyOwner {
        revert("TODO 3.2: ModularCompliance.removeModule");
    }

    // ───────────────────── Hooks, called by the token ────────────────────

    /// @dev State-changing notifications. Modules that count things
    ///      (holders, balances, daily volume) update their books here.
    function transferred(address _from, address _to, uint256 _amount) external onlyToken {
        revert("TODO 3.3: ModularCompliance.transferred");
    }

    function created(address _to, uint256 _amount) external onlyToken {
        revert("TODO 3.3: ModularCompliance.created");
    }

    function destroyed(address _from, uint256 _amount) external onlyToken {
        revert("TODO 3.3: ModularCompliance.destroyed");
    }

    /// @notice Would every module allow this transfer?
    function canTransfer(address _from, address _to, uint256 _amount) external view returns (bool) {
        // TODO 3.3
        // - With zero modules, what should this return?
        // - Why is the check (view) separated from the notification
        //   (transferred)? Think about what a wallet UI wants to ask before
        //   sending a transaction.
        revert("TODO 3.3: ModularCompliance.canTransfer");
    }

    // ────────────────────────────── Views ────────────────────────────────

    function getModules() external view returns (address[] memory) {
        revert("TODO 3.2: ModularCompliance.getModules");
    }

    function getTokenBound() external view returns (address) {
        revert("TODO 3.1: ModularCompliance.getTokenBound");
    }

    function isModuleBound(address _module) external view returns (bool) {
        revert("TODO 3.2: ModularCompliance.isModuleBound");
    }
}
