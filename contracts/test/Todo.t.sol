// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {BaseTest} from "./Base.t.sol";
import {FundingPool} from "../src/FundingPool.sol";
import {InvoiceMath} from "../src/InvoiceMath.sol";

/// @dev These suites are the spec for the three functions you implement.
///      They fail until the matching TODO is done.

/// TODO 1: InvoiceMath.advanceAmount
contract InvoiceMathTest is Test {
    function test_sixtyDaysAtEighteenAndAQuarterPercent() public pure {
        // 18.25% a year for 60 days = 3% of face value.
        assertEq(InvoiceMath.advanceAmount(10_000e6, 1825, 60 days), 9_700e6);
    }

    function test_fullYearTakesTheWholeAnnualRate() public pure {
        assertEq(InvoiceMath.advanceAmount(10_000e6, 1000, 365 days), 9_000e6);
    }

    function test_zeroRateMeansNoDiscount() public pure {
        assertEq(InvoiceMath.advanceAmount(10_000e6, 0, 60 days), 10_000e6);
    }

    function testFuzz_advanceNeverExceedsFaceValue(uint128 face, uint16 bps, uint32 tenor) public pure {
        bps = uint16(bound(bps, 0, 5_000));
        tenor = uint32(bound(tenor, 0, 365 days));
        assertLe(InvoiceMath.advanceAmount(face, bps, tenor), face);
    }
}

/// TODO 2: FundingPool._claimAmount
contract ClaimTest is BaseTest {
    function test_fullRepaymentSplitsFaceValueProRata() public {
        uint256 id = _fundedRound();
        vm.prank(oracle);
        pool.settle(id, FACE);

        uint256 aliceBefore = usdc.balanceOf(alice);
        uint256 bobBefore = usdc.balanceOf(bob);
        vm.prank(alice);
        pool.claim(id);
        vm.prank(bob);
        pool.claim(id);

        // Alice holds 6,000 of 9,700 shares; Bob holds 3,700.
        uint256 alicePayout = usdc.balanceOf(alice) - aliceBefore;
        uint256 bobPayout = usdc.balanceOf(bob) - bobBefore;
        assertEq(alicePayout, (6_000e6 * FACE) / TARGET);
        assertEq(bobPayout, (3_700e6 * FACE) / TARGET);
        assertGt(alicePayout, 6_000e6, "alice should earn yield");
    }

    function test_claimOrderDoesNotChangePayouts() public {
        uint256 id = _fundedRound();
        vm.prank(oracle);
        pool.settle(id, FACE);

        uint256 bobBefore = usdc.balanceOf(bob);
        vm.prank(bob); // Bob first this time
        pool.claim(id);
        vm.prank(alice);
        pool.claim(id);

        assertEq(usdc.balanceOf(bob) - bobBefore, (3_700e6 * FACE) / TARGET);
    }

    function test_poolNeverPaysOutMoreThanItHolds() public {
        uint256 id = _fundedRound();
        vm.prank(oracle);
        pool.settle(id, FACE);
        vm.prank(alice);
        pool.claim(id);
        vm.prank(bob);
        pool.claim(id);
        // Rounding dust may remain, but never more than 1 unit per claimant.
        assertLe(usdc.balanceOf(address(pool)), 2);
    }

    function test_defaultSplitsPartialRecoveryProRata() public {
        uint256 id = _fundedRound();
        vm.prank(oracle);
        pool.settle(id, 4_850e6); // debtor paid half the funding target, then vanished
        vm.warp(dueDate + pool.GRACE_PERIOD() + 1);
        pool.markDefaulted(id);

        uint256 aliceBefore = usdc.balanceOf(alice);
        vm.prank(alice);
        pool.claim(id);
        assertEq(usdc.balanceOf(alice) - aliceBefore, 3_000e6); // half of her 6,000
    }

    function test_defaultWithNoRecoveryPaysNothing() public {
        uint256 id = _fundedRound();
        vm.warp(dueDate + pool.GRACE_PERIOD() + 1);
        pool.markDefaulted(id);

        uint256 aliceBefore = usdc.balanceOf(alice);
        vm.prank(alice);
        pool.claim(id);
        assertEq(usdc.balanceOf(alice), aliceBefore);
        assertEq(pool.balanceOf(alice, id), 0);
    }
}

/// TODO 3: FundingPool._update (transfer restrictions)
contract TransferRestrictionTest is BaseTest {
    function test_sharesMoveBetweenKycedInvestors() public {
        uint256 id = _fundedRound();
        vm.prank(alice);
        pool.safeTransferFrom(alice, bob, id, 1_000e6, "");
        assertEq(pool.balanceOf(bob, id), 4_700e6);
    }

    function test_revertWhen_transferringToUnverifiedWallet() public {
        uint256 id = _fundedRound();
        vm.prank(alice);
        vm.expectRevert(FundingPool.NotVerified.selector);
        pool.safeTransferFrom(alice, stranger, id, 1_000e6, "");
    }

    function test_revertWhen_senderLostKyc() public {
        uint256 id = _fundedRound();
        vm.prank(admin);
        registry.setVerified(alice, false);
        vm.prank(alice);
        vm.expectRevert(FundingPool.NotVerified.selector);
        pool.safeTransferFrom(alice, bob, id, 1_000e6, "");
    }
}
