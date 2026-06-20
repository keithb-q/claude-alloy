import { Router } from 'express';
import { getLevel, recordPurchase, recordSale } from '../data/stockStore.js';

const router = Router();

router.get('/level/:upc', (req, res) => {
  const level = getLevel(req.params.upc);
  if (level === null) return res.status(404).end();
  res.json({ level });
});

router.post('/purchase/:upc', (req, res) => {
  const quantity = Number(req.body.quantity);
  if (!Number.isInteger(quantity) || quantity <= 0) return res.status(400).end();
  recordPurchase(req.params.upc, quantity);
  res.status(201).end();
});

router.post('/sale/:upc', (req, res) => {
  const quantity = Number(req.body.quantity);
  if (!Number.isInteger(quantity) || quantity <= 0) return res.status(400).end();
  recordSale(req.params.upc, quantity);
  res.status(201).end();
});

export default router;
