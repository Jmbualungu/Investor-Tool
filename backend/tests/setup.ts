/**
 * Test setup and global configuration
 */

// Set test environment
process.env.NODE_ENV = 'test';
process.env.PORT = '8080';
process.env.LOG_LEVEL = 'error'; // Reduce noise during tests

// Mock environment variables for testing
process.env.MARKET_DATA_API_KEY = 'test-api-key';
process.env.FINANCIAL_API_KEY = 'test-financial-key';

// Increase timeout for integration tests
jest.setTimeout(10000);

// Suppress console output during tests (optional)
global.console = {
  ...console,
  log: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  // Keep error for debugging
};
