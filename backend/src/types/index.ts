import { Request } from 'express';

/**
 * Extended Express Request with custom properties
 */
export interface RequestWithId extends Request {
  id: string;
  startTime: number;
}

/**
 * Standard API response format
 */
export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: {
    message: string;
    code?: string;
    details?: unknown;
  };
  meta?: {
    requestId: string;
    timestamp: string;
  };
}

/**
 * Health check response
 */
export interface HealthResponse {
  ok: boolean;
  version: string;
  env: string;
  uptime: number;
  timestamp: string;
}

/**
 * Market data sample response
 */
export interface MarketDataSample {
  symbol: string;
  price: number;
  timestamp: string;
  source: string;
}

/**
 * Application configuration
 */
export interface AppConfig {
  port: number;
  nodeEnv: string;
  logLevel: string;
  enableRateLimiting: boolean;
  apiKeys: {
    openai?: string;
    marketData?: string;
    financial?: string;
  };
}

/**
 * Error codes
 */
export enum ErrorCode {
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  NOT_FOUND = 'NOT_FOUND',
  INTERNAL_ERROR = 'INTERNAL_ERROR',
  UNAUTHORIZED = 'UNAUTHORIZED',
  RATE_LIMITED = 'RATE_LIMITED',
  EXTERNAL_API_ERROR = 'EXTERNAL_API_ERROR',
}
