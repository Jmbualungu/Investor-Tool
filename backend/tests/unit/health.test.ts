import request from 'supertest';
import { createApp } from '../../src/app';

describe('Health Routes', () => {
  const app = createApp();

  describe('GET /health', () => {
    it('should return 200 and health status', async () => {
      const response = await request(app)
        .get('/health')
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body).toMatchObject({
        success: true,
        data: {
          ok: true,
          version: expect.any(String),
          env: 'test',
          uptime: expect.any(Number),
          timestamp: expect.any(String),
        },
      });
    });

    it('should include valid timestamp in ISO format', async () => {
      const response = await request(app).get('/health');
      
      const timestamp = response.body.data.timestamp;
      expect(timestamp).toBeTruthy();
      expect(new Date(timestamp).toISOString()).toBe(timestamp);
    });

    it('should return positive uptime', async () => {
      const response = await request(app).get('/health');
      
      expect(response.body.data.uptime).toBeGreaterThanOrEqual(0);
    });
  });

  describe('GET /health/config', () => {
    it('should return 200 and sanitized config', async () => {
      const response = await request(app)
        .get('/health/config')
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body).toMatchObject({
        success: true,
        data: {
          port: expect.any(Number),
          nodeEnv: expect.any(String),
          logLevel: expect.any(String),
          enableRateLimiting: expect.any(Boolean),
          apiKeys: expect.any(Object),
        },
      });
    });

    it('should NOT expose actual API keys', async () => {
      const response = await request(app).get('/health/config');
      
      const apiKeys = response.body.data.apiKeys;
      expect(apiKeys.marketData).not.toBe('test-api-key');
      expect(apiKeys.financial).not.toBe('test-financial-key');
      expect(apiKeys.marketData).toMatch(/\*\*\*configured\*\*\*/);
    });
  });

  describe('404 Not Found', () => {
    it('should return 404 for non-existent routes', async () => {
      const response = await request(app)
        .get('/this-route-does-not-exist')
        .expect('Content-Type', /json/)
        .expect(404);

      expect(response.body).toMatchObject({
        success: false,
        error: {
          message: expect.stringContaining('not found'),
          code: 'NOT_FOUND',
        },
        meta: {
          requestId: expect.any(String),
          timestamp: expect.any(String),
        },
      });
    });
  });
});
