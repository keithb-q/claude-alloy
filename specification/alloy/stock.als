module stock

-- UPC-E barcode used to identify items in queries
sig UpcE {}

-- Items known to the system, each uniquely identified by a UPC-E
sig StockItem {
    upc  : one UpcE,
    level: one Int
} {
    level >= 0
}

-- UPC-E is a unique identifier
fact UpcUnique {
    all disj a, b: StockItem | a.upc != b.upc
}

-- HTTP response status codes used by this API
abstract sig Status {}
one sig HTTP_200 extends Status {}
one sig HTTP_404 extends Status {}

-- Response document for a stock level query
sig StockLevelResponse {
    status  : one Status,
    quantity: lone Int       -- absent on 404
}

-- Story 1: GET …/stock/level/{upc}
-- Pure query; no state is modified (CQS)
pred queryStockLevel[u: UpcE, r: StockLevelResponse] {
    (some u.~upc) => {
        r.status   = HTTP_200
        r.quantity = u.~upc.level
    } else {
        r.status = HTTP_404
        no r.quantity
    }
}

-- A known item returns 200 with its level
assert KnownItemGets200 {
    all u: UpcE, r: StockLevelResponse |
        (some u.~upc and queryStockLevel[u, r]) =>
            (r.status = HTTP_200 and one r.quantity)
}

-- An unknown item returns 404 with no body
assert UnknownItemGets404 {
    all u: UpcE, r: StockLevelResponse |
        (no u.~upc and queryStockLevel[u, r]) =>
            (r.status = HTTP_404 and no r.quantity)
}

check KnownItemGets200   for 4
check UnknownItemGets404 for 4

run queryStockLevel for 3
