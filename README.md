# Invoice Financing RWA

A project for learning ERC-3643 (T-REX), the permissioned-token standard for
real-world assets, by building it. The use case: a verified business
tokenizes an unpaid invoice, eligible investors fund it at a discount in
stablecoin and receive ERC-3643 share tokens, and they are repaid with yield
when the debtor pays.

**Start here: [LEARNING_PATH.md](LEARNING_PATH.md).**

The ERC-3643 contracts are a skeleton: interfaces, storage, events and
function signatures match the standard, and every body is a numbered TODO
for you to write.

## Layout

| Folder | What | Status |
|---|---|---|
| `contracts/src/erc3643/` | ONCHAINID, registries, compliance, token | Skeleton, phases 1 to 5 |
| `contracts/src/` | Invoice NFT, funding pool, share token factory | Written, 3 TODOs (phase 6) |
| `backend/` | Claim issuer, verifier attestation, settlement oracle, indexer | Placeholder |
| `frontend/` | Issuer, investor and admin views | Placeholder |

## Contracts

| Contract | Role | Phase |
|---|---|---|
| `erc3643/identity/Identity` | Investor's ONCHAINID: keys and claims | 1 |
| `erc3643/identity/ClaimIssuer` | KYC provider: validates and revokes claims | 1 |
| `erc3643/roles/AgentRole` | Owner vs agent split | 2 |
| `erc3643/registry/ClaimTopicsRegistry` | Which claims are required | 2 |
| `erc3643/registry/TrustedIssuersRegistry` | Whose claims count | 2 |
| `erc3643/registry/IdentityRegistryStorage` | Wallet -> identity, shared across tokens | 2 |
| `erc3643/registry/IdentityRegistry` | `isVerified(wallet)` | 2 |
| `erc3643/compliance/ModularCompliance` | `canTransfer`, fans out to modules | 3 |
| `erc3643/token/Token` | Permissioned ERC-20: pause, freeze, forced transfer, recovery | 4 |
| `erc3643/compliance/modules/*` | Country restriction, max balance per investor | 5 |
| `ShareTokenFactory` | One share token per invoice | 6 |
| `FundingPool` | Funding rounds, settlement, default | 6 |
| `InvoiceNFT` | One ERC-721 per verified invoice (EIP-712 attested) | done |
| `InvoiceMath` | Discount pricing | 6 |
| `MockUSDC` | Testnet stablecoin with a faucet | done |

Round lifecycle:

```
Funding ──> Funded ──> Repaid
   │           └─────> Defaulted
   └─> Cancelled (deadline missed, investors refunded)
```

## Running

```bash
git clone --recurse-submodules https://github.com/lizgeorge1/invoice-financing-rwa.git
```

```bash
cd contracts && forge test
```

Right now 7 tests pass (`InvoiceNFT`) and 4 fail (`InvoiceMath`, TODO 6.2).
There are no ERC-3643 tests yet: writing them is part of each step.

`foundry.toml` silences three compiler warnings that empty function bodies
trigger. Remove that line when the skeleton is filled in.

## Known simplifications

- Not a drop-in T-REX: no proxies, no batch functions, simplified ONCHAINID.
  The full list is at the end of the learning path.
- One trusted verifier key and one trusted oracle key.
- Default is final: recoveries after `markDefaulted` are not supported.
- No legal wrapper. In production an SPV or assignment agreement is what
  makes the token an enforceable claim on the receivable.
- No platform fee.
