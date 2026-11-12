// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title IdentityRegistry
/// @notice On-chain allowlist of wallets that passed off-chain KYC.
/// @dev Trust assumption: the owner (the backend's KYC operator key) only
///      verifies wallets that really passed KYC. This is a simplified take on
///      the identity registry in ERC-3643.
contract IdentityRegistry is Ownable {
    mapping(address => bool) private _verified;

    event VerificationUpdated(address indexed account, bool verified);

    constructor(address kycOperator) Ownable(kycOperator) {}

    function setVerified(address account, bool verified) external onlyOwner {
        _verified[account] = verified;
        emit VerificationUpdated(account, verified);
    }

    function isVerified(address account) external view returns (bool) {
        return _verified[account];
    }
}
