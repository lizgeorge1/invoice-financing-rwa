// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseTest} from "./Base.t.sol";
import {InvoiceNFT} from "../src/InvoiceNFT.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract IdentityRegistryTest is BaseTest {
    function test_onlyOperatorCanVerify() public {
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, stranger));
        registry.setVerified(stranger, true);
    }

    function test_verificationCanBeRevoked() public {
        vm.prank(admin);
        registry.setVerified(alice, false);
        assertFalse(registry.isVerified(alice));
    }
}

contract InvoiceNFTTest is BaseTest {
    function test_mintWithVerifierSignature() public {
        uint256 id = _mintInvoice();
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
        data.faceValue = FACE * 10; // issuer inflates the amount
        vm.prank(issuer);
        vm.expectRevert(InvoiceNFT.InvalidSignature.selector);
        nft.mint(data, sig);
    }

    function test_revertWhen_sameDocumentMintedTwice() public {
        _mintInvoice();
        InvoiceNFT.Invoice memory data = _invoice(keccak256("invoice-001.pdf"));
        bytes memory sig = _sign(data, verifierKey);
        vm.prank(issuer);
        vm.expectRevert(InvoiceNFT.DocumentAlreadyUsed.selector);
        nft.mint(data, sig);
    }

    function test_revertWhen_callerIsNotIssuer() public {
        InvoiceNFT.Invoice memory data = _invoice(keccak256("a"));
        bytes memory sig = _sign(data, verifierKey);
        vm.prank(alice);
        vm.expectRevert(InvoiceNFT.NotIssuer.selector);
        nft.mint(data, sig);
    }

    function test_revertWhen_issuerLosesKyc() public {
        InvoiceNFT.Invoice memory data = _invoice(keccak256("a"));
        bytes memory sig = _sign(data, verifierKey);
        vm.prank(admin);
        registry.setVerified(issuer, false);
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
