// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title AgentRole
/// @notice PHASE 2. ERC-3643 splits power in two: the **owner** configures
///         (which registries, which rules) and **agents** operate (register
///         investors, mint, freeze, force transfers).
contract AgentRole is Ownable {
    mapping(address => bool) internal _agents;

    event AgentAdded(address indexed _agent);
    event AgentRemoved(address indexed _agent);

    constructor(address initialOwner) Ownable(initialOwner) {}

    modifier onlyAgent() {
        // TODO 2.1: replace this revert with the real check.
        revert("TODO 2.1: AgentRole.onlyAgent");
        _;
    }

    function addAgent(address _agent) public onlyOwner {
        revert("TODO 2.1: AgentRole.addAgent");
    }

    function removeAgent(address _agent) public onlyOwner {
        revert("TODO 2.1: AgentRole.removeAgent");
    }

    function isAgent(address _agent) public view returns (bool) {
        revert("TODO 2.1: AgentRole.isAgent");
    }
}
