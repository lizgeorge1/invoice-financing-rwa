// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AgentRole} from "../roles/AgentRole.sol";
import {IToken} from "../interfaces/IToken.sol";
import {IIdentityRegistry} from "../interfaces/IIdentityRegistry.sol";
import {IModularCompliance} from "../interfaces/IModularCompliance.sol";

/// @title Token (ERC-3643 permissioned ERC-20)
/// @notice PHASE 4. An ERC-20 where every balance change is gated by the
///         Identity Registry (who) and the Compliance (what), and where
///         agents hold the powers a regulated issuer is legally required
///         to have: pause, freeze, force a transfer, recover a lost wallet.
/// @dev Balances, allowances and `_mint/_burn/_transfer` come from
///      OpenZeppelin's ERC20. Everything specific to ERC-3643 is yours.
contract Token is IToken, ERC20, AgentRole {
    string internal _tokenName;
    string internal _tokenSymbol;
    uint8 internal _tokenDecimals;
    address internal _tokenOnchainID;
    bool internal _tokenPaused;

    mapping(address wallet => bool) internal _frozen;
    mapping(address wallet => uint256) internal _frozenTokens;

    IIdentityRegistry internal _tokenIdentityRegistry;
    IModularCompliance internal _tokenCompliance;

    constructor(
        address identityRegistry_,
        address compliance_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address onchainID_,
        address initialOwner
    ) ERC20("", "") AgentRole(initialOwner) {
        // TODO 4.1
        // - Store the metadata, registry and compliance; emit the events.
        // - The official token starts PAUSED. Why is that a sensible default
        //   for a security?
        // - The compliance needs to learn which token it serves (TODO 3.1).
    }

    modifier whenNotPaused() {
        // TODO 4.1: replace this revert with the real check.
        revert("TODO 4.1: Token.whenNotPaused");
        _;
    }

    modifier whenPaused() {
        // TODO 4.1: replace this revert with the real check.
        revert("TODO 4.1: Token.whenPaused");
        _;
    }

    // ───────────────────────── Owner: configuration ──────────────────────

    function setName(string calldata _name) external onlyOwner {
        revert("TODO 4.1: Token.setName");
    }

    function setSymbol(string calldata _symbol) external onlyOwner {
        revert("TODO 4.1: Token.setSymbol");
    }

    function setOnchainID(address _onchainID) external onlyOwner {
        revert("TODO 4.1: Token.setOnchainID");
    }

    function setIdentityRegistry(address _identityRegistry) public onlyOwner {
        revert("TODO 4.1: Token.setIdentityRegistry");
    }

    function setCompliance(address _compliance) public onlyOwner {
        // TODO 4.1: unbind the old compliance, bind the new one.
        revert("TODO 4.1: Token.setCompliance");
    }

    // ───────────────────────────── Agent: pause ──────────────────────────

    function pause() external onlyAgent whenNotPaused {
        revert("TODO 4.1: Token.pause");
    }

    function unpause() external onlyAgent whenPaused {
        revert("TODO 4.1: Token.unpause");
    }

    // ────────────────────────── Agent: mint / burn ───────────────────────

    function mint(address _to, uint256 _amount) public onlyAgent {
        // TODO 4.2
        // - Which checks apply to a mint? The official code requires the
        //   receiver to be verified AND compliance.canTransfer(0, to, amount).
        // - After minting, compliance must be told (`created`).
        // - Is mint blocked while paused? Check the official token.
        revert("TODO 4.2: Token.mint");
    }

    function burn(address _userAddress, uint256 _amount) public onlyAgent {
        // TODO 4.2
        // - An agent burns someone else's tokens with no allowance.
        // - If the amount exceeds the wallet's *free* balance, the official
        //   code unfreezes the difference first. Why?
        revert("TODO 4.2: Token.burn");
    }

    // ───────────────────────────── Transfers ─────────────────────────────

    function transfer(address _to, uint256 _amount) public override(ERC20, IERC20) whenNotPaused returns (bool) {
        // TODO 4.3: the function the whole standard exists for.
        //
        // Order of checks in the official token:
        //   1. neither sender nor receiver wallet is frozen
        //   2. amount <= balance - frozenTokens
        //   3. identityRegistry.isVerified(_to) && compliance.canTransfer(...)
        //   4. move the tokens, then compliance.transferred(...)
        //
        // - Only the RECEIVER is identity-checked. What does that mean for
        //   a holder whose KYC claim is revoked after they bought?
        revert("TODO 4.3: Token.transfer");
    }

    function transferFrom(address _from, address _to, uint256 _amount)
        public
        override(ERC20, IERC20)
        whenNotPaused
        returns (bool)
    {
        // TODO 4.3: same gates as `transfer`, plus the allowance.
        // - Whose frozen status matters here: _from, _to, msg.sender?
        revert("TODO 4.3: Token.transferFrom");
    }

    // ───────────────────────────── Agent: freeze ─────────────────────────

    function setAddressFrozen(address _userAddress, bool _freeze) public onlyAgent {
        revert("TODO 4.4: Token.setAddressFrozen");
    }

    function freezePartialTokens(address _userAddress, uint256 _amount) public onlyAgent {
        // TODO 4.4: cannot freeze more than the wallet holds.
        revert("TODO 4.4: Token.freezePartialTokens");
    }

    function unfreezePartialTokens(address _userAddress, uint256 _amount) public onlyAgent {
        revert("TODO 4.4: Token.unfreezePartialTokens");
    }

    // ─────────────────────── Agent: forced transfer ──────────────────────

    function forcedTransfer(address _from, address _to, uint256 _amount) public onlyAgent returns (bool) {
        // TODO 4.5
        // - Bypasses: pause, wallet freeze, partial freeze, compliance check.
        // - Does NOT bypass: the receiver must still be verified.
        // - Compliance is still notified so module books stay correct.
        revert("TODO 4.5: Token.forcedTransfer");
    }

    // ─────────────────────────── Agent: recovery ─────────────────────────

    function recoveryAddress(address _lostWallet, address _newWallet, address _investorOnchainID)
        external
        onlyAgent
        returns (bool)
    {
        // TODO 4.6: the investor lost their key; move everything to a new
        // wallet tied to the SAME identity.
        //
        // - Proof the new wallet belongs to the investor: it is a
        //   MANAGEMENT key on `_investorOnchainID`.
        // - Register the new wallet (same identity, same country), move the
        //   tokens, carry over both kinds of freeze, delete the old wallet.
        // - This is the payoff of Phase 1: the identity outlives the wallet.
        revert("TODO 4.6: Token.recoveryAddress");
    }

    // ────────────────────────────── Views ────────────────────────────────

    function name() public view override(ERC20, IToken) returns (string memory) {
        revert("TODO 4.1: Token.name");
    }

    function symbol() public view override(ERC20, IToken) returns (string memory) {
        revert("TODO 4.1: Token.symbol");
    }

    function decimals() public view override(ERC20, IToken) returns (uint8) {
        revert("TODO 4.1: Token.decimals");
    }

    function onchainID() external view returns (address) {
        revert("TODO 4.1: Token.onchainID");
    }

    function identityRegistry() external view returns (IIdentityRegistry) {
        revert("TODO 4.1: Token.identityRegistry");
    }

    function compliance() external view returns (IModularCompliance) {
        revert("TODO 4.1: Token.compliance");
    }

    function paused() external view returns (bool) {
        revert("TODO 4.1: Token.paused");
    }

    function isFrozen(address _userAddress) external view returns (bool) {
        revert("TODO 4.4: Token.isFrozen");
    }

    function getFrozenTokens(address _userAddress) external view returns (uint256) {
        revert("TODO 4.4: Token.getFrozenTokens");
    }
}
