// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IIdentityRegistry} from "./erc3643/interfaces/IIdentityRegistry.sol";

/// @title ShareTokenFactory
/// @notice PHASE 6. Deploys one ERC-3643 token per invoice. Every share
///         token points at the SAME Identity Registry, so an investor is
///         onboarded once and can fund any invoice.
contract ShareTokenFactory is Ownable {
    IIdentityRegistry public immutable identityRegistry;
    address public pool;

    event PoolSet(address indexed pool);
    event ShareTokenCreated(uint256 indexed invoiceId, address indexed token, address indexed compliance);

    error NotPool();

    constructor(IIdentityRegistry identityRegistry_, address admin) Ownable(admin) {
        identityRegistry = identityRegistry_;
    }

    function setPool(address pool_) external onlyOwner {
        pool = pool_;
        emit PoolSet(pool_);
    }

    /// @notice Deploy the compliance and token for one invoice.
    /// @dev Called by FundingPool.openRound.
    function createShareToken(uint256 invoiceId) external returns (address token) {
        // TODO 6.1
        // - Only the pool may call.
        // - Deploy a ModularCompliance, then a Token wired to the shared
        //   identity registry and that compliance. Use 6 decimals so one
        //   share equals one stablecoin unit.
        // - The pool mints on `fund` and burns on `claim`/`refund`. Which
        //   role does it need on the token?
        // - The token starts paused. Unpause it, or leave shares
        //   non-transferable until the round is Funded?
        // - This contract is the first owner of what it deploys. Who should
        //   own the token and compliance when this function returns?
        revert("TODO 6.1: ShareTokenFactory.createShareToken");
    }
}
