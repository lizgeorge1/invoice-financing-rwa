// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IClaimTopicsRegistry} from "../interfaces/IClaimTopicsRegistry.sol";

/// @title ClaimTopicsRegistry
/// @notice PHASE 2. "To hold this token you need claims on these topics."
///         Topics are plain numbers the ecosystem agrees on (for example
///         1 = KYC, 2 = accredited investor).
contract ClaimTopicsRegistry is IClaimTopicsRegistry, Ownable {
    uint256[] internal _claimTopics;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function addClaimTopic(uint256 _claimTopic) external onlyOwner {
        // TODO 2.2
        // - Reject duplicates.
        // - isVerified loops over this array on every transfer. The official
        //   code caps it at 15 topics. Why is an unbounded list dangerous?
        revert("TODO 2.2: ClaimTopicsRegistry.addClaimTopic");
    }

    function removeClaimTopic(uint256 _claimTopic) external onlyOwner {
        revert("TODO 2.2: ClaimTopicsRegistry.removeClaimTopic");
    }

    function getClaimTopics() external view returns (uint256[] memory) {
        revert("TODO 2.2: ClaimTopicsRegistry.getClaimTopics");
    }
}
