# Review — round ending 2026-06-20

Opportunities to improve, in the order specified by the workflow.

---

## Implementation

- `stockStore.js` holds state in module-level arrays. Because Node caches modules on `import`, the store is shared across all requests in a single process but is silently wiped on server restart. There is no persistence, no signal that data was lost, and no test that detects this.

- No validation of the UPC-E format. Any string is accepted as a UPC-E identifier. A malformed or excessively long UPC-E will silently be stored.

- No guard against negative stock. A sale that exceeds cumulative purchases produces a negative level, which is returned without error. Whether this is permissible is undefined.

- `recordPurchase` and `recordSale` are exported and callable directly from any module, bypassing the HTTP layer. The hexagonal architecture principle requires the store to sit behind a port, not be callable from outside the domain.

---

## Tests

- Tests are execution-order-dependent. "POST sale decreases stock level" reads a level that was modified by "POST purchase increases stock level" on the same UPC (`03456781`). A test runner that randomises order or runs tests in isolation will produce different results.

- The seed data is load-bearing for several tests. "known UPC returns 200 with level" passes only because the server happens to have been seeded with `01234565 → 42`. Tests should establish their own preconditions.

- No test for the POST response body. The spec says the body is a "key-value" but tests only assert the HTTP status code.

- No test for a quantity of zero, a non-integer quantity, or a missing body, even though the implementation rejects them with 400.

- No test for the negative-stock case.

- No test that the accumulated level is correct after a sequence of mixed purchases and sales on the same UPC-E.

---

## Formal spec

- The events-at-system-boundary idiom was not applied in the previous version. Fixed in this round: `RecordedPurchase` and `RecordedSale` are now `var sig` subsets that grow monotonically, each event predicate carries a full frame condition, and the `Evt` enum with derived `fun` relations makes events visible in the visualiser.

- Two new assertions have been added — `PurchaseIncreasesLevel` and `SaleDecreasesLevel` — that express the exact level change caused by each command. These are now checked and return UNSAT.

- The pool of static `Purchase` and `Sale` atoms is a Alloy modelling artefact with no counterpart in the real system: every possible transaction exists from time zero and is merely "unrecorded". This is a consequence of Alloy's closed-world assumption and is unavoidable, but it means the model cannot express "a new UPC-E identifier arriving that was never seen before" — all UpcE atoms are also present from the start.

- The scope `for 3 but 5 steps` is uniform across all checks and runs. No scope was tuned to the minimum needed for each command.

- There is no assertion that the ledger is monotonic (transactions are never un-recorded). This follows from the structure of the event predicates and the traces fact, but it is not stated explicitly and is therefore not checked.

---

## Natural-language spec

- "Unknown" is never defined. The formal model defines it as "no Purchase or Sale references this UPC-E", but a reader of `requirements.md` cannot recover that definition. An item purchased and then sold back to zero is *known with level 0*, not *unknown* — the spec does not draw this distinction.

- The format of the POST request body is described only as "a key-value … saying the number received". The key name is unspecified. The current implementation uses `quantity`; the spec should name it.

- There is no story for what happens when a sale quantity exceeds the current level. This is a boundary condition the system must handle one way or another.

- Story 1.1 says "a document containing the current level" but does not name the field in the document. The implementation uses `level`; the spec should be explicit.
