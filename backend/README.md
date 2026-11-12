# Backend (not started)

Planned TypeScript service. Build it after the contract TODOs are green.

| Module | Job | Talks to |
|---|---|---|
| KYC | Mock approval, then `IdentityRegistry.setVerified` | Registry (operator key) |
| Invoices | Upload PDF, store it, compute `documentHash` | IPFS or object storage, Postgres |
| Verifier | Sign the EIP-712 `Invoice` struct for approved invoices | Verifier key only, no transactions |
| Oracle | Bank webhook (simulated) -> `FundingPool.settle` | Pool (oracle key, holds stablecoin) |
| Indexer | Follow contract events into Postgres for the API | RPC |

The EIP-712 domain is `{ name: "InvoiceNFT", version: "1", chainId, verifyingContract }`
and the type is
`Invoice(address issuer,uint256 faceValue,uint64 dueDate,bytes32 documentHash)`.
Check your signature against `InvoiceNFT.hashInvoice` before wiring anything else.

Suggested stack: Fastify or Hono, viem, Drizzle, Postgres.
