import express from 'express';
import cors from 'cors';

const PORT = process.env.PORT ?? 3001;

const app = express();

app.use(cors({ origin: 'http://localhost:5173' }));
app.use(express.json());

app.get('/api/health', (_req, res) => res.json({ status: 'ok' }));

app.listen(PORT, () => {
  console.log(`BFF server listening on http://localhost:${PORT}`);
});