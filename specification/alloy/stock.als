module stock

sig UpcE {}

-- All transactions that could ever occur live in a static pool.
-- RecordedPurchase and RecordedSale are the subsets that have actually been
-- posted to the API; both grow monotonically as events arrive.
sig Purchase {
    upc      : one UpcE,
    quantity : one Int
} {
    quantity > 0
}

sig Sale {
    upc      : one UpcE,
    quantity : one Int
} {
    quantity > 0
}

var sig RecordedPurchase in Purchase {}
var sig RecordedSale     in Sale     {}

-- HTTP response infrastructure

abstract sig Status {}
one sig HTTP_200 extends Status {}
one sig HTTP_404 extends Status {}

sig StockLevelResponse {
    status   : one Status,
    quantity : lone Int
}

-- Derived state (evaluated against the current ledger at each time step)

fun knownItems : set UpcE {
    RecordedPurchase.upc + RecordedSale.upc
}

fun purchasesFor[u: UpcE] : set Purchase {
    { p : RecordedPurchase | p.upc = u }
}

fun salesFor[u: UpcE] : set Sale {
    { s : RecordedSale | s.upc = u }
}

-- minus[] is required: - between sum expressions is set difference in Alloy
fun stockLevel[u: UpcE] : Int {
    minus[(sum p : purchasesFor[u] | p.quantity),
          (sum s : salesFor[u]     | s.quantity)]
}

-- Initial state: nothing has been posted yet

fact init {
    no RecordedPurchase
    no RecordedSale
}

-- Scope guard: with for-3 scope and 5-bit Int (max 15), three atoms × 4 = 12 ≤ 15.
-- Without this, the solver picks quantities that overflow sum[], producing spurious counterexamples.
fact quantityBound {
    all p: Purchase | p.quantity <= 4
    all s: Sale     | s.quantity <= 4
}

-- Events at the system boundary
-- Each predicate names the guard and the full frame on the ledger state.

-- Story 2: POST /stock/purchase/{upc}
pred recordPurchase[p: Purchase] {
    p not in RecordedPurchase
    RecordedPurchase' = RecordedPurchase + p
    RecordedSale'     = RecordedSale
}

-- Story 3: POST /stock/sale/{upc}
pred recordSale[s: Sale] {
    s not in RecordedSale
    RecordedPurchase' = RecordedPurchase
    RecordedSale'     = RecordedSale + s
}

-- Story 1: GET /stock/level/{upc}  (pure query — no state change)
pred queryStockLevel[u: UpcE, r: StockLevelResponse] {
    RecordedPurchase' = RecordedPurchase
    RecordedSale'     = RecordedSale
    (u in knownItems) => {
        r.status   = HTTP_200
        r.quantity = stockLevel[u]
    } else {
        r.status = HTTP_404
        no r.quantity
    }
}

pred stutter {
    RecordedPurchase' = RecordedPurchase
    RecordedSale'     = RecordedSale
}

-- Every step is one of the four events above

fact traces {
    always (
        stutter
        or (some p: Purchase | recordPurchase[p])
        or (some s: Sale     | recordSale[s])
        or (some u: UpcE, r: StockLevelResponse | queryStockLevel[u, r])
    )
}

-- Event depiction idiom
-- Derived relations that make the active event visible in the visualiser.

enum Evt { Stutter, RecordPurchase, RecordSale, QueryStockLevel }

fun stutter_evt : set Evt {
    { e: Stutter | stutter }
}

fun recordPurchase_evt : Evt -> Purchase {
    { e: RecordPurchase, p: Purchase | recordPurchase[p] }
}

fun recordSale_evt : Evt -> Sale {
    { e: RecordSale, s: Sale | recordSale[s] }
}

fun queryStockLevel_evt : Evt -> UpcE {
    { e: QueryStockLevel, u: UpcE | some r: StockLevelResponse | queryStockLevel[u, r] }
}

fun events : set Evt {
    stutter_evt
    + recordPurchase_evt.Purchase
    + recordSale_evt.Sale
    + queryStockLevel_evt.UpcE
}

-- Assertions

assert KnownItemGets200 {
    always (all u: UpcE, r: StockLevelResponse |
        (u in knownItems and queryStockLevel[u, r]) =>
            (r.status = HTTP_200 and one r.quantity))
}

assert UnknownItemGets404 {
    always (all u: UpcE, r: StockLevelResponse |
        (u not in knownItems and queryStockLevel[u, r]) =>
            (r.status = HTTP_404 and no r.quantity))
}

-- Recording a purchase increases the level for its UpcE by exactly the purchase quantity.
-- lvl captures the level in the current state so it can be compared across the transition.
assert PurchaseIncreasesLevel {
    always (all p: Purchase, lvl: Int |
        (recordPurchase[p] and stockLevel[p.upc] = lvl) =>
            after (stockLevel[p.upc] = plus[lvl, p.quantity]))
}

-- Recording a sale decreases the level for its UpcE by exactly the sale quantity.
assert SaleDecreasesLevel {
    always (all s: Sale, lvl: Int |
        (recordSale[s] and stockLevel[s.upc] = lvl) =>
            after (stockLevel[s.upc] = minus[lvl, s.quantity]))
}

check KnownItemGets200       for 3 but 5 Int, 5 steps
check UnknownItemGets404     for 3 but 5 Int, 5 steps
check PurchaseIncreasesLevel for 3 but 5 Int, 5 steps
check SaleDecreasesLevel     for 3 but 5 Int, 5 steps

run { eventually some p: Purchase | recordPurchase[p] }   for 3 but 5 Int, 5 steps
run { eventually some s: Sale     | recordSale[s] }       for 3 but 5 Int, 5 steps
run { eventually (some u: UpcE, r: StockLevelResponse |
      u in knownItems and queryStockLevel[u, r]) }         for 3 but 5 Int, 5 steps
