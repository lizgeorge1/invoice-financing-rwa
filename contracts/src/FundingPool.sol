// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IdentityRegistry} from "./IdentityRegistry.sol";
import {InvoiceNFT} from "./InvoiceNFT.sol";
import {InvoiceMath} from "./InvoiceMath.sol";

/// @title FundingPool
/// @notice Runs one funding round per invoice. Investors deposit stablecoin
///         and receive ERC-1155 shares (token id = invoice id, 1 share per
///         stablecoin unit deposited). The invoice NFT sits in escrow here.
/// @dev Trust assumption: `oracle` only calls `settle` when the debtor has
///      really paid off-chain, and funds the call with that money.
///
///      Lifecycle:  Funding -> Funded -> Repaid
///                     |          `----> Defaulted
///                     `-> Cancelled (deadline passed, investors refunded)
contract FundingPool is ERC1155, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    enum Status {
        None,
        Funding,
        Funded,
        Repaid,
        Defaulted,
        Cancelled
    }

    struct Round {
        address issuer;
        uint256 faceValue; // what the debtor owes at maturity
        uint256 fundingTarget; // what investors pay in total; also the total share supply once funded
        uint256 raised; // deposited so far
        uint256 repaid; // settled by the oracle so far
        uint64 fundingDeadline;
        uint64 dueDate;
        Status status;
    }

    /// @notice How long after the due date before anyone can declare default.
    uint64 public constant GRACE_PERIOD = 15 days;

    IERC20 public immutable stablecoin;
    IdentityRegistry public immutable registry;
    InvoiceNFT public immutable invoiceNft;
    address public oracle;

    mapping(uint256 invoiceId => Round) public rounds;

    event RoundOpened(
        uint256 indexed invoiceId, address indexed issuer, uint256 fundingTarget, uint64 fundingDeadline
    );
    event Funded(uint256 indexed invoiceId, address indexed investor, uint256 amount);
    event AdvancePaid(uint256 indexed invoiceId, address indexed issuer, uint256 amount);
    event RoundCancelled(uint256 indexed invoiceId);
    event Refunded(uint256 indexed invoiceId, address indexed investor, uint256 amount);
    event Settled(uint256 indexed invoiceId, uint256 amount, uint256 totalRepaid);
    event Defaulted(uint256 indexed invoiceId, uint256 totalRepaid);
    event Claimed(uint256 indexed invoiceId, address indexed investor, uint256 shares, uint256 payout);
    event OracleUpdated(address indexed oracle);

    error NotVerified();
    error NotIssuer();
    error NotOracle();
    error WrongStatus(Status current);
    error InvalidDeadline();
    error DeadlinePassed();
    error DeadlineNotPassed();
    error ExceedsTarget();
    error ExceedsFaceValue();
    error GracePeriodNotOver();
    error ZeroAmount();

    modifier onlyVerified() {
        if (!registry.isVerified(msg.sender)) revert NotVerified();
        _;
    }

    constructor(IERC20 stablecoin_, IdentityRegistry registry_, InvoiceNFT invoiceNft_, address oracle_, address admin)
        ERC1155("")
        Ownable(admin)
    {
        stablecoin = stablecoin_;
        registry = registry_;
        invoiceNft = invoiceNft_;
        oracle = oracle_;
    }

    function setOracle(address oracle_) external onlyOwner {
        oracle = oracle_;
        emit OracleUpdated(oracle_);
    }

    // ───────────────────────────── Issuer ─────────────────────────────

    /// @notice Escrow an invoice NFT and open it for funding.
    /// @param annualDiscountBps Annualized discount the issuer offers investors.
    function openRound(uint256 invoiceId, uint256 annualDiscountBps, uint64 fundingDeadline) external onlyVerified {
        InvoiceNFT.Invoice memory inv = invoiceNft.getInvoice(invoiceId);
        if (msg.sender != inv.issuer || invoiceNft.ownerOf(invoiceId) != msg.sender) revert NotIssuer();
        if (fundingDeadline <= block.timestamp || fundingDeadline >= inv.dueDate) revert InvalidDeadline();

        uint256 target = InvoiceMath.advanceAmount(inv.faceValue, annualDiscountBps, inv.dueDate - block.timestamp);

        rounds[invoiceId] = Round({
            issuer: inv.issuer,
            faceValue: inv.faceValue,
            fundingTarget: target,
            raised: 0,
            repaid: 0,
            fundingDeadline: fundingDeadline,
            dueDate: inv.dueDate,
            status: Status.Funding
        });

        invoiceNft.transferFrom(msg.sender, address(this), invoiceId);
        emit RoundOpened(invoiceId, inv.issuer, target, fundingDeadline);
    }

    // ──────────────────────────── Investors ───────────────────────────

    /// @notice Deposit stablecoin into a round. When the target is reached
    ///         the advance is paid to the issuer in the same transaction.
    function fund(uint256 invoiceId, uint256 amount) external onlyVerified nonReentrant {
        Round storage r = rounds[invoiceId];
        if (r.status != Status.Funding) revert WrongStatus(r.status);
        if (block.timestamp > r.fundingDeadline) revert DeadlinePassed();
        if (amount == 0) revert ZeroAmount();
        if (r.raised + amount > r.fundingTarget) revert ExceedsTarget();

        r.raised += amount;
        stablecoin.safeTransferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, invoiceId, amount, "");
        emit Funded(invoiceId, msg.sender, amount);

        if (r.raised == r.fundingTarget) {
            r.status = Status.Funded;
            stablecoin.safeTransfer(r.issuer, r.fundingTarget);
            emit AdvancePaid(invoiceId, r.issuer, r.fundingTarget);
        }
    }

    /// @notice Cancel a round that missed its deadline. Returns the NFT to the issuer.
    function cancelRound(uint256 invoiceId) external {
        Round storage r = rounds[invoiceId];
        if (r.status != Status.Funding) revert WrongStatus(r.status);
        if (block.timestamp <= r.fundingDeadline) revert DeadlineNotPassed();

        r.status = Status.Cancelled;
        invoiceNft.transferFrom(address(this), r.issuer, invoiceId);
        emit RoundCancelled(invoiceId);
    }

    /// @notice Get a deposit back from a cancelled round.
    function refund(uint256 invoiceId) external nonReentrant {
        Round storage r = rounds[invoiceId];
        if (r.status != Status.Cancelled) revert WrongStatus(r.status);
        uint256 shares = balanceOf(msg.sender, invoiceId);
        if (shares == 0) revert ZeroAmount();

        _burn(msg.sender, invoiceId, shares);
        stablecoin.safeTransfer(msg.sender, shares);
        emit Refunded(invoiceId, msg.sender, shares);
    }

    /// @notice Burn all of the caller's shares in a finished round for their payout.
    function claim(uint256 invoiceId) external nonReentrant {
        Round storage r = rounds[invoiceId];
        if (r.status != Status.Repaid && r.status != Status.Defaulted) revert WrongStatus(r.status);
        uint256 shares = balanceOf(msg.sender, invoiceId);
        if (shares == 0) revert ZeroAmount();

        uint256 payout = _claimAmount(r, shares);
        _burn(msg.sender, invoiceId, shares);
        stablecoin.safeTransfer(msg.sender, payout);
        emit Claimed(invoiceId, msg.sender, shares, payout);
    }

    // ───────────────────────── Oracle / anyone ────────────────────────

    /// @notice Report an off-chain payment from the debtor. The oracle's
    ///         settlement account supplies the stablecoin.
    function settle(uint256 invoiceId, uint256 amount) external nonReentrant {
        if (msg.sender != oracle) revert NotOracle();
        Round storage r = rounds[invoiceId];
        if (r.status != Status.Funded) revert WrongStatus(r.status);
        if (amount == 0) revert ZeroAmount();
        if (r.repaid + amount > r.faceValue) revert ExceedsFaceValue();

        r.repaid += amount;
        stablecoin.safeTransferFrom(msg.sender, address(this), amount);
        emit Settled(invoiceId, amount, r.repaid);

        if (r.repaid == r.faceValue) r.status = Status.Repaid;
    }

    /// @notice Declare default once the grace period has passed without full
    ///         repayment. Final in this MVP: whatever was settled before this
    ///         call is all investors recover.
    function markDefaulted(uint256 invoiceId) external {
        Round storage r = rounds[invoiceId];
        if (r.status != Status.Funded) revert WrongStatus(r.status);
        if (block.timestamp <= r.dueDate + GRACE_PERIOD) revert GracePeriodNotOver();

        r.status = Status.Defaulted;
        emit Defaulted(invoiceId, r.repaid);
    }

    // ───────────────────────────── Internals ──────────────────────────

    /// @dev Stablecoin owed to a holder of `shares` in a Repaid or Defaulted round.
    function _claimAmount(Round storage r, uint256 shares) internal view returns (uint256) {
        // TODO 2 (yours): split the money in the pool between shareholders.
        //
        // Available to you: r.repaid (stablecoin the oracle settled),
        // r.faceValue, r.fundingTarget (total shares issued), r.status.
        //
        // Things to decide:
        //  - Repaid and Defaulted rounds: do they need different formulas,
        //    or does one formula cover both?
        //  - What is the denominator? `claim` burns shares as people claim,
        //    so anything based on the *live* share supply changes between
        //    the first claimant and the last. The payout must not depend on
        //    claim order.
        //  - Rounding: the pool must never owe more than it holds.
        //
        // Spec: test/Todo.t.sol -> ClaimTest
        r; shares; // silence unused warnings
        revert("TODO 2: implement FundingPool._claimAmount");
    }

    /// @dev Runs on every share mint, burn and transfer.
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal override {
        // TODO 3 (yours): enforce transfer restrictions.
        //
        // Right now shares can be sent to any wallet, which defeats the KYC
        // gate on `fund`. Revert with `NotVerified()` when a transfer
        // involves a wallet the registry has not verified.
        //
        // Things to decide:
        //  - Mints have from == address(0) and burns have to == address(0).
        //    Should those be checked? (`fund` already checks the investor.)
        //  - If an investor's KYC is revoked, should they still be able to
        //    `claim` or `refund` (a burn)? Blocking it freezes their money;
        //    allowing it lets a sanctioned wallet cash out. Real security
        //    tokens solve this with a forced-transfer role. Pick one for the
        //    MVP and leave a comment saying why.
        //
        // Spec: test/Todo.t.sol -> TransferRestrictionTest
        super._update(from, to, ids, values);
    }
}
