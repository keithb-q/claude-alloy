import { Router } from 'express';
import { getLevel } from '../data/stockStore.js';

const router = Router();

router.get('/level/:upc', (req, res) => {
  const level = getLevel(req.params.upc);
  if (level === null) return res.status(404).end();
  res.json({ level });
});

export default router;
