// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseTest} from "./Base.t.sol";
import {FundingPool} from "../src/FundingPool.sol";

/// @dev Funding, refund, settlement and default state transitions.
///      Every test here needs InvoiceMath.advanceAmount (TODO 1) because
///      opening a round prices the invoice.
contract FundingPoolTest is BaseTest {
    function test_openRoundEscrowsNftAndPricesInvoice() public {
        uint256 id = _openRound();
        assertEq(nft.ownerOf(id), address(pool));
        (,, uint256 target,,,,, FundingPool.Status status) = pool.rounds(id);
        assertEq(target, TARGET);
        assertEq(uint8(status), uint8(FundingPool.Status.Funding));
    }

    function test_revertWhen_deadlineIsAfterDueDate() public {
        uint256 id = _mintInvoice();
        vm.startPrank(issuer);
        nft.approve(address(pool), id);
        vm.expectRevert(FundingPool.InvalidDeadline.selector);
        pool.openRound(id, DISCOUNT_BPS, dueDate);
        vm.stopPrank();
    }

    function test_fundMintsSharesOneToOne() public {
        uint256 id = _openRound();
        vm.prank(alice);
        pool.fund(id, 6_000e6);
        assertEq(pool.balanceOf(alice, id), 6_000e6);
        assertEq(usdc.balanceOf(address(pool)), 6_000e6);
    }

    function test_fillingRoundPaysAdvanceToIssuer() public {
        uint256 id = _fundedRound();
        assertEq(usdc.balanceOf(issuer), TARGET);
        assertEq(usdc.balanceOf(address(pool)), 0);
        assertEq(uint8(_status(id)), uint8(FundingPool.Status.Funded));
    }

    function test_revertWhen_investorNotKyced() public {
        uint256 id = _openRound();
        vm.prank(stranger);
        vm.expectRevert(FundingPool.NotVerified.selector);
        pool.fund(id, 100e6);
    }

    function test_revertWhen_fundingExceedsTarget() public {
        uint256 id = _openRound();
        vm.prank(alice);
        vm.expectRevert(FundingPool.ExceedsTarget.selector);
        pool.fund(id, TARGET + 1);
    }

    function test_revertWhen_fundingAfterDeadline() public {
        uint256 id = _openRound();
        vm.warp(fundingDeadline + 1);
        vm.prank(alice);
        vm.expectRevert(FundingPool.DeadlinePassed.selector);
        pool.fund(id, 100e6);
    }

    function test_cancelAndRefundWhenRoundMissesDeadline() public {
        uint256 id = _openRound();
        vm.prank(alice);
        pool.fund(id, 6_000e6);
        uint256 before = usdc.balanceOf(alice);

        vm.warp(fundingDeadline + 1);
        pool.cancelRound(id);
        assertEq(nft.ownerOf(id), issuer);

        vm.prank(alice);
        pool.refund(id);
        assertEq(usdc.balanceOf(alice), before + 6_000e6);
        assertEq(pool.balanceOf(alice, id), 0);
    }

    function test_revertWhen_cancellingBeforeDeadline() public {
        uint256 id = _openRound();
        vm.expectRevert(FundingPool.DeadlineNotPassed.selector);
        pool.cancelRound(id);
    }

    function test_onlyOracleCanSettle() public {
        uint256 id = _fundedRound();
        vm.prank(issuer);
        vm.expectRevert(FundingPool.NotOracle.selector);
        pool.settle(id, FACE);
    }

    function test_partialThenFullSettlementMarksRepaid() public {
        uint256 id = _fundedRound();
        vm.startPrank(oracle);
        pool.settle(id, 4_000e6);
        assertEq(uint8(_status(id)), uint8(FundingPool.Status.Funded));
        pool.settle(id, 6_000e6);
        vm.stopPrank();
        assertEq(uint8(_status(id)), uint8(FundingPool.Status.Repaid));
        assertEq(usdc.balanceOf(address(pool)), FACE);
    }

    function test_revertWhen_settlingMoreThanFaceValue() public {
        uint256 id = _fundedRound();
        vm.prank(oracle);
        vm.expectRevert(FundingPool.ExceedsFaceValue.selector);
        pool.settle(id, FACE + 1);
    }

    function test_revertWhen_defaultingDuringGracePeriod() public {
        uint256 id = _fundedRound();
        vm.warp(dueDate + pool.GRACE_PERIOD());
        vm.expectRevert(FundingPool.GracePeriodNotOver.selector);
        pool.markDefaulted(id);
    }

    function test_anyoneCanMarkDefaultAfterGracePeriod() public {
        uint256 id = _fundedRound();
        vm.warp(dueDate + pool.GRACE_PERIOD() + 1);
        vm.prank(stranger);
        pool.markDefaulted(id);
        assertEq(uint8(_status(id)), uint8(FundingPool.Status.Defaulted));
    }

    function test_revertWhen_claimingBeforeRoundFinishes() public {
        uint256 id = _fundedRound();
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(FundingPool.WrongStatus.selector, FundingPool.Status.Funded));
        pool.claim(id);
    }
}
