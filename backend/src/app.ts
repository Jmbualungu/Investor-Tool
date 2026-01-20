import express, { Application } from 'express';
import cors from 'cors';
import morgan from 'morgan';
import 'express-async-errors'; // Enables async error handling
import { config } from './config';
import { requestLogger, errorHandler, notFoundHandler } from './middleware';
import routes from './routes';
import { logger } from './utils/logger';

/**
 * Create and configure Express application
 */
export function createApp(): Application {
  const app = express();

  // Trust proxy (important for request logging in production behind a proxy)
  app.set('trust proxy', 1);

  // CORS Configuration for iOS Simulator and local development
  // iOS Simulator uses localhost, physical device uses your machine's local IP
  const corsOptions = {
    origin: (origin: string | undefined, callback: (err: Error | null, allow?: boolean) => void) => {
      // Allow requests with no origin (like mobile apps, Postman)
      if (!origin) {
        return callback(null, true);
      }

      // Allow localhost variations for iOS Simulator
      const allowedOrigins = [
        'http://localhost:8080',
        'http://127.0.0.1:8080',
        'http://localhost:3000', // If you have a web frontend
        /^http:\/\/192\.168\.\d{1,3}\.\d{1,3}:\d+$/, // Local network IPs for physical devices
        /^http:\/\/10\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d+$/, // Alternative local network range
      ];

      const isAllowed = allowedOrigins.some(pattern => {
        if (typeof pattern === 'string') {
          return origin === pattern;
        }
        return pattern.test(origin);
      });

      if (isAllowed) {
        callback(null, true);
      } else {
        logger.warn(`CORS blocked origin: ${origin}`);
        callback(new Error('Not allowed by CORS'));
      }
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-ID'],
  };

  // Middleware
  app.use(cors(corsOptions));
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));
  
  // HTTP request logging (only in development)
  if (config.nodeEnv === 'development') {
    app.use(morgan('dev'));
  }

  // Custom request logger with requestId
  app.use(requestLogger);

  // Mount routes
  app.use(routes);

  // 404 handler (must come after all routes)
  app.use(notFoundHandler);

  // Global error handler (must be last)
  app.use(errorHandler);

  return app;
}
