// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title InvoiceMath
/// @notice Pricing maths for discounting an invoice.
library InvoiceMath {
    uint256 internal constant BPS = 10_000;
    uint256 internal constant YEAR = 365 days;

    /// @notice The amount investors pay today for an invoice worth `faceValue`
    ///         at maturity. The gap between the two is the investors' yield.
    /// @param faceValue Amount the debtor will pay at maturity.
    /// @param annualDiscountBps Annualized discount rate in basis points (1825 = 18.25% a year).
    /// @param tenor Seconds from now until the invoice is due.
    /// @return advance The amount to raise from investors and pay to the issuer.
    function advanceAmount(uint256 faceValue, uint256 annualDiscountBps, uint256 tenor)
        internal
        pure
        returns (uint256 advance)
    {
        // TODO 6.2: price the invoice.
        //
        // Use simple (non-compounding) interest, pro-rated over the tenor:
        //   discount = faceValue * rate * (tenor / YEAR)
        //   advance  = faceValue - discount
        //
        // Things to decide:
        //  - Order of operations. Solidity has no decimals, so dividing early
        //    throws away precision.
        //  - Rounding direction. Integer division rounds down. Does rounding
        //    the discount down favour the issuer or the investors, and is
        //    that who you want to favour?
        //
        // Spec: test/InvoiceMath.t.sol
        faceValue; annualDiscountBps; tenor; advance; // silence unused warnings
        revert("TODO 6.2: InvoiceMath.advanceAmount");
    }
}
