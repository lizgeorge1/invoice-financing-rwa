// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {IdentityRegistry} from "../src/IdentityRegistry.sol";
import {MockUSDC} from "../src/MockUSDC.sol";
import {InvoiceNFT} from "../src/InvoiceNFT.sol";
import {FundingPool} from "../src/FundingPool.sol";

/// @dev Shared deployment and helpers for all test suites.
abstract contract BaseTest is Test {
    IdentityRegistry internal registry;
    MockUSDC internal usdc;
    InvoiceNFT internal nft;
    FundingPool internal pool;

    address internal admin = makeAddr("admin");
    address internal oracle = makeAddr("oracle");
    address internal issuer = makeAddr("issuer");
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal stranger = makeAddr("stranger"); // never KYC'd
    address internal verifier;
    uint256 internal verifierKey;

    // 10,000 USDC due in 60 days at 18.25% a year => exactly 300 USDC discount.
    uint256 internal constant FACE = 10_000e6;
    uint256 internal constant DISCOUNT_BPS = 1825;
    uint256 internal constant TARGET = 9_700e6;
    uint64 internal dueDate;
    uint64 internal fundingDeadline;

    function setUp() public virtual {
        (verifier, verifierKey) = makeAddrAndKey("verifier");

        registry = new IdentityRegistry(admin);
        usdc = new MockUSDC();
        nft = new InvoiceNFT(registry, verifier, admin);
        pool = new FundingPool(usdc, registry, nft, oracle, admin);

        vm.startPrank(admin);
        registry.setVerified(issuer, true);
        registry.setVerified(alice, true);
        registry.setVerified(bob, true);
        vm.stopPrank();

        address[4] memory funded = [alice, bob, stranger, oracle];
        for (uint256 i = 0; i < funded.length; i++) {
            usdc.mint(funded[i], 1_000_000e6);
            vm.prank(funded[i]);
            usdc.approve(address(pool), type(uint256).max);
        }

        dueDate = uint64(block.timestamp + 60 days);
        fundingDeadline = uint64(block.timestamp + 7 days);
    }

    function _invoice(bytes32 documentHash) internal view returns (InvoiceNFT.Invoice memory) {
        return InvoiceNFT.Invoice({issuer: issuer, faceValue: FACE, dueDate: dueDate, documentHash: documentHash});
    }

    function _sign(InvoiceNFT.Invoice memory data, uint256 key) internal view returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, nft.hashInvoice(data));
        return abi.encodePacked(r, s, v);
    }

    function _mintInvoice() internal returns (uint256 invoiceId) {
        InvoiceNFT.Invoice memory data = _invoice(keccak256("invoice-001.pdf"));
        bytes memory sig = _sign(data, verifierKey);
        vm.prank(issuer);
        invoiceId = nft.mint(data, sig);
    }

    function _openRound() internal returns (uint256 invoiceId) {
        invoiceId = _mintInvoice();
        vm.startPrank(issuer);
        nft.approve(address(pool), invoiceId);
        pool.openRound(invoiceId, DISCOUNT_BPS, fundingDeadline);
        vm.stopPrank();
    }

    /// @dev Alice funds 6,000 and Bob 3,700, which fills the round.
    function _fundedRound() internal returns (uint256 invoiceId) {
        invoiceId = _openRound();
        vm.prank(alice);
        pool.fund(invoiceId, 6_000e6);
        vm.prank(bob);
        pool.fund(invoiceId, 3_700e6);
    }

    function _status(uint256 invoiceId) internal view returns (FundingPool.Status status) {
        (,,,,,,, status) = pool.rounds(invoiceId);
    }
}
