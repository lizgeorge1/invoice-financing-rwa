# ERC-3643 learning path

You write every function body. The skeleton in `contracts/src/erc3643/` gives
you the storage, events and signatures of the real standard; each body is a
`revert("TODO x.y: ...")` whose number matches a step below.

## How to work

1. Read the step here, then the comments in the file.
2. Write the tests in the "Prove it" list first (`contracts/test/erc3643/`).
   They are the spec. Writing them is half the learning.
3. Implement until they pass: `forge test --match-path "test/erc3643/*"`.
4. Answer the "Think" question in your own words before moving on.
5. Only then open the official code and diff your version against it:
   - T-REX: https://github.com/TokenySolutions/T-REX (`contracts/`)
   - ONCHAINID: https://github.com/onchain-id/solidity (`contracts/`)
   - Spec: https://eips.ethereum.org/EIPS/eip-3643

Send me a phase when it is done and I will review it.

## The picture

```
                       ┌──────────────── Token (ERC-20 + agent powers) ───────────────┐
 transfer(to, amount)  │  paused? frozen? enough unfrozen balance?                     │
 ────────────────────> │                                                               │
                       │   WHO may hold it?                 WHAT transfers are allowed? │
                       └──────────┬─────────────────────────────────────┬──────────────┘
                                  ▼                                     ▼
                         IdentityRegistry.isVerified(to)     ModularCompliance.canTransfer
                          │        │           │                        │
              ┌───────────┘        │           └──────────┐             ▼
              ▼                    ▼                      ▼        Modules (country,
   IdentityRegistryStorage   ClaimTopicsRegistry   TrustedIssuers   max balance, ...)
   wallet -> ONCHAINID       "KYC required"        Registry
              │                                    "issuer X for KYC"
              ▼                                           │
   Identity (ONCHAINID) ── holds claim signed by ──> ClaimIssuer.isClaimValid
```

Build order is bottom-up: nothing in a later phase can be tested without the
earlier ones.

---

## Phase 1: Identity and claims (ONCHAINID)

Files: `identity/Identity.sol`, `identity/ClaimIssuer.sol`

The idea: a wallet is not a person. ERC-3643 gives each investor a contract
(their ONCHAINID) that outlives any single wallet. Third parties sign
statements ("claims") about that contract, not about a wallet.

### 1.1 Keys (ERC-734)
- **Write:** constructor, `addKey`, `removeKey`, `getKeyPurposes`, `keyHasPurpose`.
- **Know:** a key is `keccak256(abi.encode(address))`. Purposes: 1 MANAGEMENT,
  2 ACTION, 3 CLAIM signer. One key can hold several purposes.
- **Prove it:**
  - the deployer's chosen wallet is a MANAGEMENT key after construction
  - a non-management caller cannot add or remove keys
  - adding the same purpose twice reverts; a second purpose is appended
  - removing a purpose leaves the key's other purposes intact
- **Think:** why store a hash of the address instead of the address?

### 1.2 Claims (ERC-735)
- **Write:** `addClaim`, `removeClaim`, `getClaim`, `getClaimIdsByTopic`.
- **Know:** `claimId = keccak256(abi.encode(issuer, topic))`. A claim is
  `(topic, scheme, issuer, signature, data, uri)`; the identity only stores
  it. Validity is the issuer's business (1.3).
- **Prove it:**
  - adding emits `ClaimAdded`, re-adding the same issuer+topic emits `ClaimChanged` and does not duplicate the topic index
  - removing clears both the claim and the topic index
  - `getClaim` on an unknown id returns zeros instead of reverting
  - a stranger cannot add a claim to someone else's identity
- **Think:** the investor chooses which claims sit on their identity. What
  stops them adding a forged one?

### 1.3 Claim validation
- **Write:** `ClaimIssuer.isClaimValid`.
- **Know:** signed message is `keccak256(abi.encode(identity, topic, data))`
  with the EIP-191 prefix. Valid means: recovered signer holds a CLAIM key on
  the issuer contract, and the signature is not revoked. In tests, sign with
  `vm.sign(issuerClaimKey, digest)`.
- **Prove it:**
  - a claim signed by the issuer's CLAIM key is valid
  - signed by a random key: invalid
  - a valid signature replayed for a *different identity*: invalid
  - changing `topic` or `data` after signing: invalid
  - malformed signature bytes return false rather than reverting
- **Think:** what breaks if the identity address is left out of the hash?

### 1.4 Revocation
- **Write:** `revokeClaimBySignature`, `isClaimRevoked`.
- **Prove it:** a revoked claim fails `isClaimValid` while still sitting on
  the investor's identity; only the issuer's management key can revoke.
- **Think:** why can't revocation depend on the investor removing the claim?

---

## Phase 2: Registries

Files: `roles/AgentRole.sol`, `registry/*.sol`

### 2.1 AgentRole
- **Write:** `onlyAgent`, `addAgent`, `removeAgent`, `isAgent`.
- **Know:** owner configures, agents operate. Every later contract uses this.
- **Prove it:** only owner adds/removes; duplicate add and unknown remove revert; events emitted.

### 2.2 ClaimTopicsRegistry
- **Write:** all three functions.
- **Prove it:** duplicates rejected; removal keeps the others; only owner.
- **Think:** why does the official code cap the list at 15?

### 2.3 TrustedIssuersRegistry
- **Write:** all eight functions.
- **Know:** two indexes (issuer -> topics, topic -> issuers) must never disagree.
- **Prove it:**
  - after `addTrustedIssuer(X, [1, 2])`, X appears under both topics
  - `updateIssuerClaimTopics(X, [2])` removes X from topic 1 only
  - `removeTrustedIssuer` clears every index
  - zero address, duplicate issuer and empty topic list revert

### 2.4 IdentityRegistryStorage
- **Write:** all nine functions.
- **Know:** only bound registries (agents) write. Binding = `addAgent` + list.
- **Prove it:** an unbound caller cannot write; bind then write works; unbind
  removes the right; double registration of a wallet reverts.
- **Think:** in this project each invoice has its own token. What would
  onboarding look like without shared storage?

### 2.5 IdentityRegistry management
- **Write:** constructor, the four agent functions, three setters, six plain views.
- **Know:** this contract owns no investor data; it delegates to storage.
  It must be bound to the storage before `registerIdentity` can work.
- **Prove it:** register/update/delete round-trip through storage with the
  right events; non-agent reverts; `contains` flips.

### 2.6 `isVerified`
- **Write:** `isVerified`. The most important function in the standard.
- **Prove it:**
  - unregistered wallet: false
  - registered, no required topics: true
  - required topic + valid claim from a trusted issuer: true
  - claim from an issuer that is *not* trusted: false
  - issuer trusted for topic 2 only, claim on topic 1: false
  - two required topics, one missing: false
  - claim revoked by the issuer: false, with no change to the identity
  - issuer removed from the trusted registry: false
  - two trusted issuers, only the second one's claim present: true
  - an issuer contract whose `isClaimValid` reverts does not brick the check
- **Think:** revoking one claim instantly changes what every token using
  this registry allows. No token storage was written. Where does the state
  that enforces the restriction actually live?

---

## Phase 3: Compliance engine

File: `compliance/ModularCompliance.sol`

Write a tiny `MockModule` in your test folder (returns a settable bool from
`moduleCheck`, counts hook calls) so this phase does not depend on Phase 5.
The mock must accept `bindCompliance`.

### 3.1 Token binding
- **Write:** `onlyToken`, `bindToken`, `unbindToken`, `getTokenBound`.
- **Prove it:** owner can bind; the token can bind itself when none is bound; a stranger cannot.

### 3.2 Module management
- **Write:** `addModule`, `removeModule`, `getModules`, `isModuleBound`.
- **Prove it:** add binds the module to this compliance; duplicates revert; remove unbinds.

### 3.3 Hooks and `canTransfer`
- **Write:** `transferred`, `created`, `destroyed`, `canTransfer`.
- **Prove it:** no modules: true; one refusing module among several: false;
  each hook reaches every module exactly once; hooks reject non-token callers.
- **Think:** why are the check (`view`) and the notification separate calls?

---

## Phase 4: The token

File: `token/Token.sol`. Test setup needs everything from Phases 1 to 3:
one verified investor, one unverified wallet, compliance with a mock module.

### 4.1 Configuration and pause
- **Write:** constructor, modifiers, setters, `pause`/`unpause`, metadata views.
- **Prove it:** starts paused; only agents pause; only owner reconfigures;
  `setCompliance` rebinds.

### 4.2 Mint and burn
- **Prove it:** mint to a verified wallet works and calls `created`; mint to
  an unverified wallet reverts; non-agent cannot mint; burn calls `destroyed`;
  burning more than the free balance releases frozen tokens first.

### 4.3 `transfer` and `transferFrom`
- **Prove it:**
  - verified -> verified succeeds and notifies compliance
  - to an unverified wallet reverts
  - compliance module says no: reverts
  - paused: reverts
  - sender frozen or receiver frozen: reverts
  - amount above balance minus frozen tokens: reverts
  - `transferFrom` also consumes allowance
  - sender whose claim was revoked can still send (only the receiver is checked)
- **Think:** is that last behaviour a bug or a feature? What tool does the
  issuer have if they disagree with it? (4.4, 4.5)

### 4.4 Freezing
- **Write:** `setAddressFrozen`, `freezePartialTokens`, `unfreezePartialTokens`, views.
- **Prove it:** cannot freeze more than balance; cannot unfreeze more than frozen; events.

### 4.5 `forcedTransfer`
- **Prove it:** works while paused, from a frozen wallet, and through
  partially frozen tokens (which get unfrozen); still reverts if the receiver
  is unverified; non-agent reverts.
- **Think:** this is the function crypto-native people object to. Which legal
  events make it unavoidable for a security (court order, inheritance, ...)?

### 4.6 `recoveryAddress`
- **Prove it:** balance, frozen amount and frozen flag all move to the new
  wallet; old wallet is deleted from the registry; reverts if the new wallet
  is not a MANAGEMENT key on the investor's ONCHAINID; emits `RecoverySuccess`.
- **Think:** which Phase 1 design decision made this possible?

---

## Phase 5: Compliance modules

Files: `compliance/modules/*.sol`

### 5.1 AbstractModule
- **Write:** `onlyComplianceCall`, `bindCompliance`, `unbindCompliance`, `isComplianceBound`.
- **Prove it:** only a compliance can bind itself. Then replace Phase 3's mock with a real module in one test.

### 5.2 CountryRestrictModule (stateless)
- **Prove it:** receiver in a restricted country is refused, end to end
  through `Token.transfer`; restrictions on compliance A do not affect
  compliance B; only A's owner can change A's settings.

### 5.3 MaxBalanceModule (stateful)
- **Prove it:** cap enforced on transfer and on mint; two wallets of the same
  ONCHAINID share one cap; burning frees room; the module's ledger equals
  token balances after a mixed sequence of mint, transfer, burn.
- **Think:** what goes wrong if a module with a ledger is added to a token
  that already has holders?

**Stretch:** implement T-REX's `callModuleFunction` on the compliance so
module settings are changed through it, and drop the `_compliance` argument
from the setters. Compare with the official modules.

---

## Phase 6: Put it to work

Files: `ShareTokenFactory.sol`, `InvoiceMath.sol`, `FundingPool.sol`

### 6.1 ShareTokenFactory
- **Write:** `createShareToken`. Decide ownership, agents and pause state.
### 6.2 `InvoiceMath.advanceAmount`
- Spec exists: `forge test --match-contract InvoiceMathTest`.
### 6.3 `FundingPool._claimAmount`
- Payout must not depend on claim order; the pool never owes more than it holds.
### 6.4 End-to-end test
Write one test that tells the whole story with real contracts and no mocks:
deploy registries and a claim issuer, onboard issuer + two investors with
signed KYC claims, mint an invoice, open a round, fund, settle, claim. Then
the regulated-asset scenarios:
- an investor sells shares to another verified investor mid-round
- a transfer to a wallet without a claim fails
- the KYC provider revokes a claim: that investor can no longer receive
- an investor loses their key and the agent recovers their shares before `claim`
- a frozen investor cannot claim until unfrozen (is that what you want?)

The old ERC-1155 pool tests are in git history (`git show 5448861:contracts/test/FundingPool.t.sol`)
if you want lifecycle cases to port.

---

## After the contracts

- **Backend:** the KYC module becomes a claim-issuer service: it signs
  `(identity, topic, data)` with the issuer's CLAIM key, and an agent key
  calls `registerIdentity`. Same hash you built in 1.3, now in viem.
- **Frontend:** an admin view for the agent powers (freeze, forced transfer,
  recovery) and an investor view that calls `isVerified` and `canTransfer`
  before offering a transfer.

## Where this skeleton differs from official T-REX

| Area | Official | Here |
|---|---|---|
| Deployment | Upgradeable proxies, `TREXFactory`, implementation authority | Plain constructors, `ShareTokenFactory` |
| Solidity / OZ | 0.8.17, OZ 4.x | 0.8.31, OZ 5.x |
| Identity | `execute`/`approve` multi-sig flow, `isClaimValid` on `IIdentity` | Keys and claims only; `isClaimValid` on `IClaimIssuer` |
| Batch functions | `batchMint`, `batchTransfer`, ... | Omitted |
| Module settings | Via `callModuleFunction` | Compliance owner calls the module (stretch goal restores it) |
| Module interface | `canComplianceBind`, `isPlugAndPlay` | Omitted |
| Token | `version()`, extra param on `UpdatedTokenInformation` | Omitted |
