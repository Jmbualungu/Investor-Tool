import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { RequestWithId } from '../types';
import { logger } from '../utils/logger';

/**
 * Request logger middleware
 * Adds a unique requestId to each request and logs method, path, status, and duration
 */
export function requestLogger(req: Request, res: Response, next: NextFunction) {
  const requestWithId = req as RequestWithId;
  
  // Generate unique request ID
  requestWithId.id = uuidv4();
  requestWithId.startTime = Date.now();

  // Store original end function
  const originalEnd = res.end;

  // Override end to log after response is sent
  res.end = function (this: Response, chunk?: any, encoding?: any, callback?: any) {
    const duration = Date.now() - requestWithId.startTime;
    
    logger.info('Request completed', {
      requestId: requestWithId.id,
      method: req.method,
      path: req.path,
      status: res.statusCode,
      duration: `${duration}ms`,
      userAgent: req.get('user-agent'),
    });

    // Call original end function
    return originalEnd.call(this, chunk, encoding, callback);
  } as typeof res.end;

  next();
}
