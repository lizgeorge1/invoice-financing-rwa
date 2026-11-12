# Invoice Financing RWA

A learning MVP for real-world asset tokenization. A verified business
tokenizes an unpaid invoice, KYC'd investors fund it at a discount in
stablecoin, and investors are repaid with yield when the debtor pays.

## Layout

| Folder | What | Status |
|---|---|---|
| `contracts/` | Foundry project: registry, invoice NFT, funding pool | Scaffolded, 3 TODOs |
| `backend/` | TypeScript: KYC, verifier attestation, settlement oracle, indexer | Placeholder |
| `frontend/` | Next.js: issuer, investor and admin views | Placeholder |

## Contracts

| Contract | Role | Off-chain party it trusts |
|---|---|---|
| `IdentityRegistry` | KYC allowlist | KYC operator |
| `InvoiceNFT` | One ERC-721 per verified invoice (EIP-712 attested) | Verifier |
| `FundingPool` | Funding rounds, ERC-1155 shares, settlement, default | Settlement oracle |
| `InvoiceMath` | Discount pricing | none |
| `MockUSDC` | Testnet stablecoin with a faucet | none |

Round lifecycle:

```
Funding ──> Funded ──> Repaid
   │           └─────> Defaulted
   └─> Cancelled (deadline missed, investors refunded)
```

## Your TODOs

Do them in order. Each has guidance in the source and a spec in
`contracts/test/Todo.t.sol`.

1. `InvoiceMath.advanceAmount` in `contracts/src/InvoiceMath.sol`: price the invoice.
2. `FundingPool._claimAmount` in `contracts/src/FundingPool.sol`: split repayments and recoveries.
3. `FundingPool._update` in `contracts/src/FundingPool.sol`: KYC transfer restrictions.

```bash
cd contracts
forge test
```

Before any TODO is done, 10 tests pass and 26 fail. TODO 1 alone turns the
14 failing `FundingPoolTest` tests and 4 `InvoiceMathTest` tests green,
because opening a round needs a price.

## Known simplifications

- One trusted verifier key and one trusted oracle key.
- Default is final: recoveries after `markDefaulted` are not supported.
- No legal wrapper. In production an SPV or assignment agreement is what
  makes the token an enforceable claim on the receivable.
- No platform fee and no secondary market.
