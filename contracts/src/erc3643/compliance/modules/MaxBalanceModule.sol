// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AbstractModule} from "./AbstractModule.sol";

/// @title MaxBalanceModule
/// @notice PHASE 5. A stateful rule: no single *investor* may hold more
///         than a cap. For an invoice this is a concentration limit.
/// @dev The cap is per ONCHAINID, not per wallet. One investor can register
///      several wallets against one identity; a per-wallet cap would be
///      trivially bypassed.
contract MaxBalanceModule is AbstractModule {
    mapping(address compliance => uint256) internal _maxBalance;
    mapping(address compliance => mapping(address identity => uint256)) internal _balanceOfIdentity;

    event MaxBalanceSet(address indexed _compliance, uint256 indexed _maxBalance);

    /// @dev Only the owner of `_compliance` may call. Same deviation from
    ///      T-REX as CountryRestrictModule.
    function setMaxBalance(address _compliance, uint256 _max) external {
        revert("TODO 5.3: MaxBalanceModule.setMaxBalance");
    }

    function maxBalance(address _compliance) external view returns (uint256) {
        revert("TODO 5.3: MaxBalanceModule.maxBalance");
    }

    function balanceOfIdentity(address _compliance, address _identity) external view returns (uint256) {
        revert("TODO 5.3: MaxBalanceModule.balanceOfIdentity");
    }

    function moduleCheck(address _from, address _to, uint256 _value, address _compliance)
        external
        view
        returns (bool)
    {
        // TODO 5.3
        // - Would the receiver's *identity* exceed the cap after receiving?
        // - A transfer between two wallets of the same identity: allowed?
        revert("TODO 5.3: MaxBalanceModule.moduleCheck");
    }

    // The module keeps its own ledger instead of reading token balances.
    // These three hooks are the only place it changes, so msg.sender (a
    // bound compliance) is the key into the mappings.

    function moduleTransferAction(address _from, address _to, uint256 _value) external onlyComplianceCall {
        revert("TODO 5.3: MaxBalanceModule.moduleTransferAction");
    }

    function moduleMintAction(address _to, uint256 _value) external onlyComplianceCall {
        // TODO 5.3: the token calls `created` AFTER minting and nothing
        // called moduleCheck first unless Token.mint asks canTransfer.
        // Decide where the cap is enforced for mints (see TODO 4.2).
        revert("TODO 5.3: MaxBalanceModule.moduleMintAction");
    }

    function moduleBurnAction(address _from, uint256 _value) external onlyComplianceCall {
        revert("TODO 5.3: MaxBalanceModule.moduleBurnAction");
    }

    function name() external pure returns (string memory _name) {
        return "MaxBalanceModule";
    }
}
