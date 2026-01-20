import { Router, Request, Response } from 'express';
import { ApiResponse, MarketDataSample, ErrorCode } from '../types';
import { marketDataService } from '../services/marketDataService';
import { AppError } from '../middleware';

const router = Router();

/**
 * GET /api/market/sample
 * Get sample market data for a symbol
 * Query params: symbol (required)
 * 
 * Example: GET /api/market/sample?symbol=AAPL
 */
router.get('/sample', async (req: Request, res: Response) => {
  const { symbol } = req.query;

  if (!symbol || typeof symbol !== 'string') {
    throw new AppError(
      400,
      'Symbol parameter is required',
      ErrorCode.VALIDATION_ERROR
    );
  }

  const data = await marketDataService.getSampleData(symbol);

  const response: ApiResponse<MarketDataSample> = {
    success: true,
    data,
  };

  res.json(response);
});

/**
 * POST /api/market/batch
 * Get market data for multiple symbols
 * Body: { symbols: string[] }
 * 
 * Example: POST /api/market/batch
 * { "symbols": ["AAPL", "MSFT", "GOOGL"] }
 */
router.post('/batch', async (req: Request, res: Response) => {
  const { symbols } = req.body;

  if (!Array.isArray(symbols)) {
    throw new AppError(
      400,
      'Request body must contain an array of symbols',
      ErrorCode.VALIDATION_ERROR
    );
  }

  const data = await marketDataService.getBatchQuotes(symbols);

  const response: ApiResponse<MarketDataSample[]> = {
    success: true,
    data,
  };

  res.json(response);
});

export default router;
