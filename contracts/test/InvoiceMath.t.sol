// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {InvoiceMath} from "../src/InvoiceMath.sol";

/// @dev Spec for TODO 6.2. Fails until `advanceAmount` is implemented.
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
