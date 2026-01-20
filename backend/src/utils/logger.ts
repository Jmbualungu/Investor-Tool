import { config } from '../config';

/**
 * Simple logger utility
 * In production, consider using winston or pino
 */
export const logger = {
  debug: (message: string, meta?: unknown) => {
    if (config.logLevel === 'debug') {
      console.log(`[DEBUG] ${message}`, meta ? JSON.stringify(meta) : '');
    }
  },

  info: (message: string, meta?: unknown) => {
    if (['debug', 'info'].includes(config.logLevel)) {
      console.log(`[INFO] ${message}`, meta ? JSON.stringify(meta) : '');
    }
  },

  warn: (message: string, meta?: unknown) => {
    if (['debug', 'info', 'warn'].includes(config.logLevel)) {
      console.warn(`[WARN] ${message}`, meta ? JSON.stringify(meta) : '');
    }
  },

  error: (message: string, error?: unknown) => {
    console.error(`[ERROR] ${message}`, error);
  },
};
