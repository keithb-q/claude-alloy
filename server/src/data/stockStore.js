// Transactions are stored as flat arrays: [{upc, quantity}, ...]
const purchases = [];
const sales = [];

// Seed: 01234565 has level 42, 02345673 has level 0 (purchases == sales), 03456781 has level 7
purchases.push({ upc: '01234565', quantity: 42 });
purchases.push({ upc: '02345673', quantity: 5 });
sales.push(    { upc: '02345673', quantity: 5 });
purchases.push({ upc: '03456781', quantity: 7 });

function isKnown(upc) {
  return purchases.some(p => p.upc === upc) || sales.some(s => s.upc === upc);
}

export function getLevel(upc) {
  if (!isKnown(upc)) return null;
  const received = purchases.filter(p => p.upc === upc).reduce((t, p) => t + p.quantity, 0);
  const issued   = sales.filter(s => s.upc === upc).reduce((t, s) => t + s.quantity, 0);
  return received - issued;
}

export function recordPurchase(upc, quantity) {
  purchases.push({ upc, quantity });
}

export function recordSale(upc, quantity) {
  sales.push({ upc, quantity });
}
