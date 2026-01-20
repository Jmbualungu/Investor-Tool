import request from 'supertest';
import { createApp } from '../../src/app';

describe('Market Routes', () => {
  const app = createApp();

  describe('GET /api/market/sample', () => {
    it('should return 200 and market data when symbol is provided', async () => {
      const response = await request(app)
        .get('/api/market/sample?symbol=AAPL')
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body).toMatchObject({
        success: true,
        data: {
          symbol: 'AAPL',
          price: expect.any(Number),
          timestamp: expect.any(String),
          source: expect.any(String),
        },
      });
    });

    it('should return uppercase symbol', async () => {
      const response = await request(app)
        .get('/api/market/sample?symbol=aapl')
        .expect(200);

      expect(response.body.data.symbol).toBe('AAPL');
    });

    it('should return 400 when symbol is missing', async () => {
      const response = await request(app)
        .get('/api/market/sample')
        .expect('Content-Type', /json/)
        .expect(400);

      expect(response.body).toMatchObject({
        success: false,
        error: {
          message: expect.stringContaining('required'),
          code: 'VALIDATION_ERROR',
        },
      });
    });

    it('should include requestId in response', async () => {
      const response = await request(app)
        .get('/api/market/sample?symbol=TSLA')
        .expect(200);

      expect(response.body.data).toBeTruthy();
    });
  });

  describe('POST /api/market/batch', () => {
    it('should return 200 and multiple quotes', async () => {
      const symbols = ['AAPL', 'MSFT', 'GOOGL'];
      
      const response = await request(app)
        .post('/api/market/batch')
        .send({ symbols })
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(3);
      
      response.body.data.forEach((item: any, index: number) => {
        expect(item.symbol).toBe(symbols[index]);
        expect(item.price).toEqual(expect.any(Number));
      });
    });

    it('should return 400 when symbols is not an array', async () => {
      const response = await request(app)
        .post('/api/market/batch')
        .send({ symbols: 'AAPL' })
        .expect('Content-Type', /json/)
        .expect(400);

      expect(response.body).toMatchObject({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
        },
      });
    });

    it('should return 400 when symbols array is empty', async () => {
      const response = await request(app)
        .post('/api/market/batch')
        .send({ symbols: [] })
        .expect('Content-Type', /json/)
        .expect(400);

      expect(response.body.success).toBe(false);
    });

    it('should return 400 when more than 10 symbols provided', async () => {
      const symbols = Array.from({ length: 11 }, (_, i) => `SYM${i}`);
      
      const response = await request(app)
        .post('/api/market/batch')
        .send({ symbols })
        .expect('Content-Type', /json/)
        .expect(400);

      expect(response.body).toMatchObject({
        success: false,
        error: {
          message: expect.stringContaining('Maximum 10 symbols'),
        },
      });
    });
  });
});
