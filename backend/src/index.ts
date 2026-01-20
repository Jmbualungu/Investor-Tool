import { createApp } from './app';
import { config, getSanitizedConfig } from './config';
import { logger } from './utils/logger';

/**
 * Start the server
 */
function startServer() {
  const app = createApp();

  const server = app.listen(config.port, () => {
    logger.info(`🚀 Server started successfully`);
    logger.info(`📡 Listening on port ${config.port}`);
    logger.info(`🌍 Environment: ${config.nodeEnv}`);
    logger.info(`📊 Config: ${JSON.stringify(getSanitizedConfig(), null, 2)}`);
    logger.info('');
    logger.info('Available endpoints:');
    logger.info(`  GET  http://localhost:${config.port}/health`);
    logger.info(`  GET  http://localhost:${config.port}/health/config`);
    logger.info(`  GET  http://localhost:${config.port}/api/market/sample?symbol=AAPL`);
    logger.info(`  POST http://localhost:${config.port}/api/market/batch`);
    logger.info('');
    logger.info('For iOS Simulator, use: http://localhost:8080');
    logger.info('For physical device, use: http://<your-local-ip>:8080');
  });

  // Graceful shutdown
  const shutdown = (signal: string) => {
    logger.info(`${signal} received, shutting down gracefully...`);
    server.close(() => {
      logger.info('Server closed');
      process.exit(0);
    });

    // Force shutdown after 10 seconds
    setTimeout(() => {
      logger.error('Forced shutdown after timeout');
      process.exit(1);
    }, 10000);
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

// Start server if this file is run directly
if (require.main === module) {
  startServer();
}

export { createApp };
