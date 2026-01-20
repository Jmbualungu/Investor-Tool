import { Router, Request, Response } from 'express';
import { HealthResponse, ApiResponse } from '../types';
import { config, getSanitizedConfig } from '../config';

const router = Router();

/**
 * GET /health
 * Health check endpoint - safe to call frequently
 * Returns server status without exposing secrets
 */
router.get('/', (_req: Request, res: Response) => {
  const uptime = process.uptime();
  
  const healthData: HealthResponse = {
    ok: true,
    version: '1.0.0',
    env: config.nodeEnv,
    uptime: Math.floor(uptime),
    timestamp: new Date().toISOString(),
  };

  const response: ApiResponse<HealthResponse> = {
    success: true,
    data: healthData,
  };

  res.json(response);
});

/**
 * GET /health/config
 * Return sanitized configuration (for debugging)
 * NEVER exposes actual API keys
 */
router.get('/config', (_req: Request, res: Response) => {
  const sanitizedConfig = getSanitizedConfig();
  
  const response: ApiResponse = {
    success: true,
    data: sanitizedConfig,
  };

  res.json(response);
});

export default router;
