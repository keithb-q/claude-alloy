const stock = new Map([
  ['01234565', 42],
  ['02345673', 0],
  ['03456781', 7],
]);

export function getLevel(upc) {
  return stock.has(upc) ? stock.get(upc) : null;
}
