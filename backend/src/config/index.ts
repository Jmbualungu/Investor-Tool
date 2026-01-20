import dotenv from 'dotenv';
import { z } from 'zod';
import { AppConfig } from '../types';

// Load environment variables
dotenv.config();

/**
 * ═══════════════════════════════════════════════════════════════════════════
 * iOS-SAFE ARCHITECTURE RULE
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * THIS BACKEND IS THE ONLY PLACE WHERE THIRD-PARTY API KEYS SHOULD BE STORED.
 * 
 * iOS Client (Swift) → Backend (Node.js) → External APIs (OpenAI, Market Data, etc.)
 * 
 * CRITICAL SECURITY REQUIREMENTS:
 * 
 * ✅ DO:
 *    - Store ALL third-party API keys as environment variables (.env file)
 *    - iOS app MUST ONLY call this backend's endpoints
 *    - Backend handles all external API calls using secrets from process.env
 *    - Validate and sanitize all data before sending to iOS
 * 
 * ❌ NEVER:
 *    - Embed API keys in Swift code (hardcoded strings, plist files, etc.)
 *    - Send API keys to iOS app in any response
 *    - Log actual API key values (use sanitization functions)
 *    - Commit .env file to version control
 * 
 * ARCHITECTURE FLOW EXAMPLE:
 *    1. iOS app calls: POST /api/ai/forecast with { ticker: "AAPL", ... }
 *    2. Backend validates request
 *    3. Backend uses OPENAI_API_KEY from config to call OpenAI API
 *    4. Backend returns processed forecast data to iOS
 *    5. iOS never sees or needs the OpenAI API key
 * 
 * This ensures:
 *    - API keys cannot be extracted from the iOS app bundle
 *    - Keys can be rotated without app updates
 *    - Usage can be monitored and rate-limited server-side
 *    - Compliance with App Store guidelines
 * ═══════════════════════════════════════════════════════════════════════════
 */

/**
 * Environment variable schema with validation
 */
const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().transform(Number).pipe(z.number().min(1).max(65535)).default('8080'),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  ENABLE_RATE_LIMITING: z.string().transform(val => val === 'true').default('false'),
  
  // API Keys - optional in development, but required when routes use them
  // NEVER expose these to the iOS client
  OPENAI_API_KEY: z.string().optional(),
  MARKET_DATA_API_KEY: z.string().optional(),
  FINANCIAL_API_KEY: z.string().optional(),
});

/**
 * Parse and validate environment variables
 */
function parseEnv() {
  try {
    const parsed = envSchema.parse({
      NODE_ENV: process.env.NODE_ENV,
      PORT: process.env.PORT,
      LOG_LEVEL: process.env.LOG_LEVEL,
      ENABLE_RATE_LIMITING: process.env.ENABLE_RATE_LIMITING,
      OPENAI_API_KEY: process.env.OPENAI_API_KEY,
      MARKET_DATA_API_KEY: process.env.MARKET_DATA_API_KEY,
      FINANCIAL_API_KEY: process.env.FINANCIAL_API_KEY,
    });

    // Warn about missing optional API keys in development
    if (parsed.NODE_ENV === 'development') {
      if (!parsed.OPENAI_API_KEY) {
        console.warn('⚠️  OPENAI_API_KEY is not set. AI features will not work.');
      }
      if (!parsed.MARKET_DATA_API_KEY) {
        console.warn('⚠️  MARKET_DATA_API_KEY is not set. Some features may not work.');
      }
      if (!parsed.FINANCIAL_API_KEY) {
        console.warn('⚠️  FINANCIAL_API_KEY is not set. Some features may not work.');
      }
    }

    return parsed;
  } catch (error) {
    if (error instanceof z.ZodError) {
      console.error('❌ Invalid environment configuration:');
      error.errors.forEach(err => {
        console.error(`  - ${err.path.join('.')}: ${err.message}`);
      });
      process.exit(1);
    }
    throw error;
  }
}

const env = parseEnv();

/**
 * Application configuration object
 * Centralized, validated config - safe to use throughout the app
 */
export const config: AppConfig = {
  port: env.PORT,
  nodeEnv: env.NODE_ENV,
  logLevel: env.LOG_LEVEL,
  enableRateLimiting: env.ENABLE_RATE_LIMITING,
  apiKeys: {
    openai: env.OPENAI_API_KEY,
    marketData: env.MARKET_DATA_API_KEY,
    financial: env.FINANCIAL_API_KEY,
  },
};

/**
 * Get a sanitized version of config safe for logging
 * NEVER logs actual API keys - this is critical for security
 */
export function getSanitizedConfig() {
  return {
    port: config.port,
    nodeEnv: config.nodeEnv,
    logLevel: config.logLevel,
    enableRateLimiting: config.enableRateLimiting,
    apiKeys: {
      openai: config.apiKeys.openai ? '***configured***' : 'not set',
      marketData: config.apiKeys.marketData ? '***configured***' : 'not set',
      financial: config.apiKeys.financial ? '***configured***' : 'not set',
    },
  };
}

/**
 * Check if a required API key is configured
 */
export function requireApiKey(keyName: keyof AppConfig['apiKeys']): string {
  const key = config.apiKeys[keyName];
  if (!key) {
    throw new Error(`Required API key '${keyName}' is not configured. Check your .env file.`);
  }
  return key;
}
