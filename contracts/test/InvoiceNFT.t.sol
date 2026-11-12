// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {InvoiceNFT} from "../src/InvoiceNFT.sol";
import {IIdentityRegistry} from "../src/erc3643/interfaces/IIdentityRegistry.sol";

/// @dev The identity registry is mocked with `vm.mockCall`, so this suite
///      passes before any ERC-3643 code exists. Once Phase 2 is done, swap
///      the mock for your real IdentityRegistry.
contract InvoiceNFTTest is Test {
    InvoiceNFT internal nft;
    address internal registry = makeAddr("registry");
    address internal admin = makeAddr("admin");
    address internal issuer = makeAddr("issuer");
    address internal alice = makeAddr("alice");
    address internal verifier;
    uint256 internal verifierKey;

    uint256 internal constant FACE = 10_000e6;
    uint64 internal dueDate;

    function setUp() public {
        (verifier, verifierKey) = makeAddrAndKey("verifier");
        nft = new InvoiceNFT(IIdentityRegistry(registry), verifier, admin);
        dueDate = uint64(block.timestamp + 60 days);
        _setVerified(issuer, true);
    }

    function _setVerified(address wallet, bool ok) internal {
        vm.mockCall(registry, abi.encodeCall(IIdentityRegistry.isVerified, (wallet)), abi.encode(ok));
    }

    function _invoice(bytes32 documentHash) internal view returns (InvoiceNFT.Invoice memory) {
        return InvoiceNFT.Invoice({issuer: issuer, faceValue: FACE, dueDate: dueDate, documentHash: documentHash});
    }

    function _sign(InvoiceNFT.Invoice memory data, uint256 key) internal view returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, nft.hashInvoice(data));
        return abi.encodePacked(r, s, v);
    }

    function test_mintWithVerifierSignature() public {
        InvoiceNFT.Invoice memory data = _invoice(keccak256("invoice-001.pdf"));
        bytes memory sig = _sign(data, verifierKey);
        vm.prank(issuer);
        uint256 id = nft.mint(data, sig);

        assertEq(nft.ownerOf(id), issuer);
        InvoiceNFT.Invoice memory inv = nft.getInvoice(id);
        assertEq(inv.faceValue, FACE);
        assertEq(inv.dueDate, dueDate);
    }

    function test_revertWhen_signedByWrongKey() public {
        InvoiceNFT.Invoice memory data = _invoice(keccak256("a"));
        (, uint256 wrongKey) = makeAddrAndKey("impostor");
        bytes memory sig = _sign(data, wrongKey);
        vm.prank(issuer);
        vm.expectRevert(InvoiceNFT.InvalidSignature.selector);
        nft.mint(data, sig);
    }

    function test_revertWhen_fieldsChangedAfterSigning() public {
        InvoiceNFT.Invoice memory data = _invoice(keccak256("a"));
        bytes memory sig = _sign(data, verifierKey);
        data.faceValue = FACE * 10;
        vm.prank(issuer);
        vm.expectRevert(InvoiceNFT.InvalidSignature.selector);
        nft.mint(data, sig);
    }

    function test_revertWhen_sameDocumentMintedTwice() public {
        InvoiceNFT.Invoice memory data = _invoice(keccak256("a"));
        bytes memory sig = _sign(data, verifierKey);
        vm.startPrank(issuer);
        nft.mint(data, sig);
        vm.expectRevert(InvoiceNFT.DocumentAlreadyUsed.selector);
        nft.mint(data, sig);
        vm.stopPrank();
    }

    function test_revertWhen_callerIsNotIssuer() public {
        InvoiceNFT.Invoice memory data = _invoice(keccak256("a"));
        bytes memory sig = _sign(data, verifierKey);
        vm.prank(alice);
        vm.expectRevert(InvoiceNFT.NotIssuer.selector);
        nft.mint(data, sig);
    }

    function test_revertWhen_issuerNotVerified() public {
        InvoiceNFT.Invoice memory data = _invoice(keccak256("a"));
        bytes memory sig = _sign(data, verifierKey);
        _setVerified(issuer, false);
        vm.prank(issuer);
        vm.expectRevert(InvoiceNFT.IssuerNotVerified.selector);
        nft.mint(data, sig);
    }

    function test_revertWhen_alreadyDue() public {
        InvoiceNFT.Invoice memory data = _invoice(keccak256("a"));
        data.dueDate = uint64(block.timestamp);
        bytes memory sig = _sign(data, verifierKey);
        vm.prank(issuer);
        vm.expectRevert(InvoiceNFT.InvalidInvoice.selector);
        nft.mint(data, sig);
    }
}
