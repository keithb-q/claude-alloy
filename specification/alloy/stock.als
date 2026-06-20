module stock

-- UPC-E barcode used to identify items in queries
sig UpcE {}

-- A stock receipt: a quantity of a UPC-E added to stock
sig Purchase {
    upc      : one UpcE,
    quantity : one Int
} {
    quantity > 0
}

-- A stock issue: a quantity of a UPC-E removed from stock
sig Sale {
    upc      : one UpcE,
    quantity : one Int
} {
    quantity > 0
}

-- UpcEs that have appeared in at least one transaction
fun knownItems : set UpcE {
    Purchase.upc + Sale.upc
}

-- All purchases for a given UpcE
fun purchasesFor[u: UpcE] : set Purchase {
    { p : Purchase | p.upc = u }
}

-- All sales for a given UpcE
fun salesFor[u: UpcE] : set Sale {
    { s : Sale | s.upc = u }
}

-- Current level: sum of received minus sum of issued, initial value 0
-- minus[] is used explicitly because - between sum expressions is set difference in Alloy
fun stockLevel[u: UpcE] : Int {
    minus[(sum p : purchasesFor[u] | p.quantity),
          (sum s : salesFor[u]     | s.quantity)]
}

-- HTTP response status codes used by this API
abstract sig Status {}
one sig HTTP_200 extends Status {}
one sig HTTP_404 extends Status {}

-- Response document for a stock level query
sig StockLevelResponse {
    status   : one Status,
    quantity : lone Int       -- absent on 404
}

-- Story 1: GET …/stock/level/{upc}
-- Pure query; no state is modified (CQS)
pred queryStockLevel[u: UpcE, r: StockLevelResponse] {
    (u in knownItems) => {
        r.status   = HTTP_200
        r.quantity = stockLevel[u]
    } else {
        r.status = HTTP_404
        no r.quantity
    }
}

-- Story 2: POST …/stock/purchase/{upc}
-- Records receipt of stock; increases level
pred recordPurchase[u: UpcE, qty: Int] {
    qty > 0
    some p : Purchase | p.upc = u and p.quantity = qty
}

-- Story 3: POST …/stock/sale/{upc}
-- Records issue of stock; decreases level
pred recordSale[u: UpcE, qty: Int] {
    qty > 0
    some s : Sale | s.upc = u and s.quantity = qty
}

-- A known item returns 200 with its current level
assert KnownItemGets200 {
    all u: UpcE, r: StockLevelResponse |
        (u in knownItems and queryStockLevel[u, r]) =>
            (r.status = HTTP_200 and one r.quantity)
}

-- An unknown item returns 404 with no body
assert UnknownItemGets404 {
    all u: UpcE, r: StockLevelResponse |
        (u not in knownItems and queryStockLevel[u, r]) =>
            (r.status = HTTP_404 and no r.quantity)
}

-- Recording a purchase makes the item known
assert PurchaseMakesKnown {
    all u: UpcE, qty: Int |
        recordPurchase[u, qty] => u in knownItems
}

check KnownItemGets200   for 4
check UnknownItemGets404 for 4
check PurchaseMakesKnown for 4

run queryStockLevel for 3
run recordPurchase  for 3
run recordSale      for 3
