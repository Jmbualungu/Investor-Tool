import { Router } from 'express';
import healthRouter from './health';
import marketRouter from './market';

const router = Router();

// Mount route handlers
router.use('/health', healthRouter);
router.use('/api/market', marketRouter);

export default router;
