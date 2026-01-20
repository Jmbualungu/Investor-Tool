import { config } from '../config';
import { MarketDataSample, ErrorCode } from '../types';
import { AppError } from '../middleware';
import { logger } from '../utils/logger';

/**
 * Market Data Service
 * 
 * Demonstrates the API key vaulting pattern:
 * - API keys are stored in environment variables
 * - Keys are read from centralized config
 * - Keys are never logged or exposed in responses
 * - iOS app calls this backend, backend calls third-party API
 * 
 * In production, replace placeholder logic with actual API calls
 */
export class MarketDataService {
  /**
   * Get sample market data
   * This is a placeholder that demonstrates the pattern
   */
  async getSampleData(symbol: string): Promise<MarketDataSample> {
    // Validate API key is configured
    const apiKey = config.apiKeys.marketData;
    
    if (!apiKey) {
      logger.warn('Market data API key not configured');
      throw new AppError(
        503,
        'Market data service is not configured',
        ErrorCode.EXTERNAL_API_ERROR,
        { reason: 'API key missing' }
      );
    }

    logger.info(`Fetching market data for ${symbol}`);

    try {
      // PLACEHOLDER: In production, call actual API here
      // Example:
      // const response = await fetch(`https://api.example.com/quote/${symbol}`, {
      //   headers: {
      //     'Authorization': `Bearer ${apiKey}`,
      //     'Content-Type': 'application/json'
      //   }
      // });
      // const data = await response.json();

      // For now, return mock data
      const mockData: MarketDataSample = {
        symbol: symbol.toUpperCase(),
        price: Math.random() * 1000,
        timestamp: new Date().toISOString(),
        source: 'placeholder',
      };

      logger.info(`Successfully fetched data for ${symbol}`);
      return mockData;

    } catch (error) {
      logger.error('Failed to fetch market data', error);
      throw new AppError(
        502,
        'Failed to fetch market data from external API',
        ErrorCode.EXTERNAL_API_ERROR,
        { originalError: error instanceof Error ? error.message : 'Unknown error' }
      );
    }
  }

  /**
   * Example: Get multiple quotes
   * Demonstrates batching pattern
   */
  async getBatchQuotes(symbols: string[]): Promise<MarketDataSample[]> {
    // Validate input
    if (!symbols || symbols.length === 0) {
      throw new AppError(
        400,
        'No symbols provided',
        ErrorCode.VALIDATION_ERROR
      );
    }

    if (symbols.length > 10) {
      throw new AppError(
        400,
        'Maximum 10 symbols allowed per batch',
        ErrorCode.VALIDATION_ERROR
      );
    }

    // Fetch data for each symbol
    const results = await Promise.all(
      symbols.map(symbol => this.getSampleData(symbol))
    );

    return results;
  }

  /**
   * Health check for external API
   */
  async healthCheck(): Promise<boolean> {
    const apiKey = config.apiKeys.marketData;
    
    if (!apiKey) {
      return false;
    }

    // PLACEHOLDER: In production, ping actual API
    return true;
  }
}

// Export singleton instance
export const marketDataService = new MarketDataService();
