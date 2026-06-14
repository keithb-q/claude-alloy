import { test, expect } from '@playwright/test';

test('known UPC returns 200 with level', async ({ request }) => {
  const res = await request.get('/stock/level/01234565');
  expect(res.status()).toBe(200);
  const body = await res.json();
  expect(typeof body.level).toBe('number');
});

test('item with zero stock returns 200 with level 0', async ({ request }) => {
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
