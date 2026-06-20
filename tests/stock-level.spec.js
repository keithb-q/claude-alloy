import { test, expect } from '@playwright/test';

test('known UPC returns 200 with level', async ({ request }) => {
  const res = await request.get('/stock/level/01234565');
  expect(res.status()).toBe(200);
  const body = await res.json();
  expect(typeof body.level).toBe('number');
});

test('item with zero net stock returns 200 with level 0', async ({ request }) => {
  const res = await request.get('/stock/level/02345673');
  expect(res.status()).toBe(200);
  const body = await res.json();
  expect(body.level).toBe(0);
});

test('unknown UPC returns 404 with empty body', async ({ request }) => {
  const res = await request.get('/stock/level/00000000');
  expect(res.status()).toBe(404);
  const text = await res.text();
  expect(text).toBe('');
});

test('POST purchase increases stock level', async ({ request }) => {
  const before = await (await request.get('/stock/level/03456781')).json();
  await request.post('/stock/purchase/03456781', { data: { quantity: 10 } });
  const after = await (await request.get('/stock/level/03456781')).json();
  expect(after.level).toBe(before.level + 10);
});

test('POST sale decreases stock level', async ({ request }) => {
  const before = await (await request.get('/stock/level/03456781')).json();
  await request.post('/stock/sale/03456781', { data: { quantity: 3 } });
  const after = await (await request.get('/stock/level/03456781')).json();
  expect(after.level).toBe(before.level - 3);
});

test('UPC unknown before any activity returns 404', async ({ request }) => {
  const res = await request.get('/stock/level/09999999');
  expect(res.status()).toBe(404);
});

test('UPC becomes known after first purchase', async ({ request }) => {
  await request.post('/stock/purchase/08888888', { data: { quantity: 5 } });
  const res = await request.get('/stock/level/08888888');
  expect(res.status()).toBe(200);
  const body = await res.json();
  expect(body.level).toBe(5);
});
