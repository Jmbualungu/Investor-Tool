import { Request, Response, NextFunction } from 'express';
import { ApiResponse, ErrorCode, RequestWithId } from '../types';
import { logger } from '../utils/logger';

/**
 * Custom application error class
 */
export class AppError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public code?: ErrorCode,
    public details?: unknown
  ) {
    super(message);
    this.name = 'AppError';
    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * Global error handler middleware
 * Returns consistent JSON error responses
 */
export function errorHandler(
  err: Error | AppError,
  req: Request,
  res: Response,
  _next: NextFunction
) {
  const requestWithId = req as RequestWithId;
  
  // Default to 500 internal server error
  let statusCode = 500;
  let errorCode = ErrorCode.INTERNAL_ERROR;
  let message = 'An unexpected error occurred';
  let details: unknown = undefined;

  // Handle known AppError instances
  if (err instanceof AppError) {
    statusCode = err.statusCode;
    message = err.message;
    errorCode = err.code || ErrorCode.INTERNAL_ERROR;
    details = err.details;
  } else {
    // Log unexpected errors
    logger.error('Unexpected error:', {
      requestId: requestWithId.id,
      error: err.message,
      stack: err.stack,
    });
  }

  // Build error response
  const errorResponse: ApiResponse = {
    success: false,
    error: {
      message,
      code: errorCode,
      details: details || undefined,
    },
    meta: {
      requestId: requestWithId.id,
      timestamp: new Date().toISOString(),
    },
  };

  res.status(statusCode).json(errorResponse);
}

/**
 * 404 Not Found handler
 */
export function notFoundHandler(req: Request, _res: Response, next: NextFunction) {
  next(new AppError(404, `Route ${req.method} ${req.path} not found`, ErrorCode.NOT_FOUND));
}
