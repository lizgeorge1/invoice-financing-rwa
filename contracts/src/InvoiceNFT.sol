// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IIdentityRegistry} from "./erc3643/interfaces/IIdentityRegistry.sol";

/// @title InvoiceNFT
/// @notice One token per verified real-world invoice.
/// @dev Trust assumption: `verifier` only signs invoices it has checked
///      off-chain (the document is real, the debtor confirmed it, and it has
///      not been financed elsewhere).
contract InvoiceNFT is ERC721, EIP712, Ownable {
    struct Invoice {
        address issuer; // the business that is owed the money
        uint256 faceValue; // amount the debtor owes, in stablecoin units
        uint64 dueDate; // unix timestamp the debtor must pay by
        bytes32 documentHash; // keccak256 of the invoice PDF stored off-chain
    }

    bytes32 public constant INVOICE_TYPEHASH =
        keccak256("Invoice(address issuer,uint256 faceValue,uint64 dueDate,bytes32 documentHash)");

    IIdentityRegistry public immutable registry;
    address public verifier;
    uint256 public nextTokenId = 1;

    mapping(uint256 tokenId => Invoice) private _invoices;
    /// @notice Blocks tokenizing the same document twice (double financing).
    mapping(bytes32 documentHash => bool) public documentUsed;

    event InvoiceMinted(
        uint256 indexed tokenId, address indexed issuer, uint256 faceValue, uint64 dueDate, bytes32 documentHash
    );
    event VerifierUpdated(address indexed verifier);

    error NotIssuer();
    error IssuerNotVerified();
    error InvalidInvoice();
    error DocumentAlreadyUsed();
    error InvalidSignature();

    constructor(IIdentityRegistry registry_, address verifier_, address admin)
        ERC721("Tokenized Invoice", "INV")
        EIP712("InvoiceNFT", "1")
        Ownable(admin)
    {
        registry = registry_;
        verifier = verifier_;
    }

    function setVerifier(address verifier_) external onlyOwner {
        verifier = verifier_;
        emit VerifierUpdated(verifier_);
    }

    /// @notice Mint an invoice the verifier has approved off-chain.
    /// @param data The invoice fields, exactly as the verifier signed them.
    /// @param signature The verifier's EIP-712 signature over `data`.
    function mint(Invoice calldata data, bytes calldata signature) external returns (uint256 tokenId) {
        if (msg.sender != data.issuer) revert NotIssuer();
        if (!registry.isVerified(data.issuer)) revert IssuerNotVerified();
        if (data.faceValue == 0 || data.dueDate <= block.timestamp) revert InvalidInvoice();
        if (documentUsed[data.documentHash]) revert DocumentAlreadyUsed();
        if (ECDSA.recover(hashInvoice(data), signature) != verifier) revert InvalidSignature();

        documentUsed[data.documentHash] = true;
        tokenId = nextTokenId++;
        _invoices[tokenId] = data;
        _mint(data.issuer, tokenId);

        emit InvoiceMinted(tokenId, data.issuer, data.faceValue, data.dueDate, data.documentHash);
    }

    /// @notice The EIP-712 digest the verifier signs. The backend must
    ///         produce the same digest with viem's `signTypedData`.
    function hashInvoice(Invoice calldata data) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(abi.encode(INVOICE_TYPEHASH, data.issuer, data.faceValue, data.dueDate, data.documentHash))
        );
    }

    function getInvoice(uint256 tokenId) external view returns (Invoice memory) {
        _requireOwned(tokenId);
        return _invoices[tokenId];
    }
}
