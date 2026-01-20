# Investor Tool Backend API

Production-ready Express + TypeScript backend for the Investor Tool iOS app. Designed for safe third-party API integration with proper secret management, error handling, and iOS development workflow.

## 🔒 iOS-Safe Architecture (CRITICAL)

**This backend is the ONLY place where third-party API keys should exist.**

```
┌─────────────┐         ┌─────────────┐         ┌─────────────────┐
│             │         │             │         │                 │
│  iOS App    │────────▶│  Backend    │────────▶│  External APIs  │
│  (Swift)    │         │  (Node.js)  │         │  (OpenAI, etc.) │
│             │         │             │         │                 │
└─────────────┘         └─────────────┘         └─────────────────┘
     NO KEYS             ALL KEYS HERE           Provider APIs
```

### Security Rules

✅ **DO:**
- Store ALL API keys as environment variables in backend `.env` file
- iOS app ONLY calls this backend's endpoints (never calls external APIs directly)
- Backend handles all external API integrations using secrets from `process.env`
- Rotate keys server-side without requiring app updates

❌ **NEVER:**
- Embed API keys in Swift code (hardcoded strings, Info.plist, config files)
- Send API keys to iOS app in ANY response
- Commit `.env` file to version control
- Log actual API key values (use `getSanitizedConfig()`)

### Why This Matters

1. **App Store Compliance**: Embedded keys can be extracted from app bundles
2. **Security**: Keys in client code are public, even if obfuscated
3. **Flexibility**: Rotate keys without app store review
4. **Cost Control**: Monitor and rate-limit usage server-side
5. **Compliance**: Meet data protection requirements (GDPR, etc.)

### Architecture Example

```swift
// ✅ CORRECT: iOS calls backend
func getForecast(ticker: String) async throws -> Forecast {
    let url = URL(string: "\(baseURL)/api/forecast")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body = ["ticker": ticker, "horizon": "1y"]
    request.httpBody = try JSONEncoder().encode(body)
    
    // Backend uses OPENAI_API_KEY internally - iOS never sees it
    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(Forecast.self, from: data)
}

// ❌ WRONG: Never do this in iOS
let openAIKey = "sk-..." // NEVER hardcode keys!
```

## 🏗️ Architecture

```
backend/
├── src/
│   ├── config/        # Centralized configuration with env validation
│   ├── db/            # Database models and queries (future)
│   ├── middleware/    # Express middleware (logging, errors)
│   ├── routes/        # API route handlers
│   ├── services/      # Business logic and external API integrations
│   ├── types/         # TypeScript type definitions
│   ├── utils/         # Utility functions
│   ├── app.ts         # Express app configuration
│   └── index.ts       # Server entry point
├── tests/
│   ├── unit/          # Unit tests
│   └── integration/   # Integration tests
├── .env.example       # Example environment variables
├── package.json       # Dependencies and scripts
└── tsconfig.json      # TypeScript configuration
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ and npm
- Git

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment

Copy the example environment file and add your API keys:

```bash
cp .env.example .env
```

Edit `.env` with your actual values:

```bash
NODE_ENV=development
PORT=8080

# Add your API keys here
MARKET_DATA_API_KEY=your_actual_api_key
FINANCIAL_API_KEY=your_actual_financial_key
```

**⚠️ IMPORTANT**: Never commit `.env` to version control. It's already in `.gitignore`.

### 3. Start Development Server

```bash
npm run dev
```

The server will start with hot reload on `http://localhost:8080`.

You should see:

```
🚀 Server started successfully
📡 Listening on port 8080
🌍 Environment: development

Available endpoints:
  GET  http://localhost:8080/health
  GET  http://localhost:8080/health/config
  GET  http://localhost:8080/api/market/sample?symbol=AAPL
  POST http://localhost:8080/api/market/batch
```

### 4. Verify Setup

Test the health endpoint:

```bash
curl http://localhost:8080/health
```

Expected response:

```json
{
  "success": true,
  "data": {
    "ok": true,
    "version": "1.0.0",
    "env": "development",
    "uptime": 42,
    "timestamp": "2026-01-19T12:00:00.000Z"
  }
}
```

## 📱 iOS Integration

### Connecting from iOS Simulator

In your iOS app, use:

```swift
let baseURL = "http://localhost:8080"
// or
let baseURL = "http://127.0.0.1:8080"
```

Both work identically in the simulator. The backend is configured to accept requests from both origins.

### Connecting from Physical iPhone/iPad

1. Find your Mac's local IP address:

```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

You'll see something like `inet 192.168.1.123` - that's your Mac's LAN IP.

2. Use conditional compilation in your iOS app:

```swift
#if targetEnvironment(simulator)
let baseURL = "http://127.0.0.1:8080"
#else
let baseURL = "http://192.168.1.123:8080"  // Replace with your Mac's actual IP
#endif
```

3. Ensure your iPhone/iPad is on the **same Wi-Fi network** as your Mac.

### App Transport Security (ATS) for Development

By default, iOS blocks HTTP connections (requires HTTPS). For **local development only**, you need to allow HTTP in your iOS app's `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <true/>
</dict>
```

**⚠️ IMPORTANT:**
- This is ONLY for development with `localhost` and local network IPs
- **REMOVE or restrict this before App Store submission**
- For production, use HTTPS with valid SSL certificates
- Consider deploying backend to services like Railway, Heroku, or AWS with HTTPS
- Never ship an app that allows arbitrary HTTP loads to production domains

### Production HTTPS Setup

For production:

1. Deploy backend with HTTPS (Railway, Heroku, AWS, etc.)
2. Update iOS baseURL to use `https://`
3. Remove ATS exceptions from Info.plist (or scope them to specific development domains only)
4. Test with production domain before submission

### Example iOS Network Call

```swift
struct MarketDataResponse: Codable {
    let success: Bool
    let data: MarketData
}

struct MarketData: Codable {
    let symbol: String
    let price: Double
    let timestamp: String
    let source: String
}

func fetchMarketData(symbol: String) async throws -> MarketData {
    let url = URL(string: "\(baseURL)/api/market/sample?symbol=\(symbol)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let response = try JSONDecoder().decode(MarketDataResponse.self, from: data)
    return response.data
}
```

## 🔌 API Endpoints

### Health Check

**GET** `/health`

Returns server health status (safe to call frequently).

**Response:**

```json
{
  "success": true,
  "data": {
    "ok": true,
    "version": "1.0.0",
    "env": "development",
    "uptime": 42,
    "timestamp": "2026-01-19T12:00:00.000Z"
  }
}
```

### Health Config (Debug)

**GET** `/health/config`

Returns sanitized configuration (API keys are masked).

### Market Data Sample

**GET** `/api/market/sample?symbol={SYMBOL}`

Get sample market data for a single symbol.

**Query Parameters:**

- `symbol` (required): Stock symbol (e.g., AAPL, MSFT)

**Response:**

```json
{
  "success": true,
  "data": {
    "symbol": "AAPL",
    "price": 178.42,
    "timestamp": "2026-01-19T12:00:00.000Z",
    "source": "placeholder"
  }
}
```

### Market Data Batch

**POST** `/api/market/batch`

Get market data for multiple symbols (max 10).

**Request Body:**

```json
{
  "symbols": ["AAPL", "MSFT", "GOOGL"]
}
```

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "symbol": "AAPL",
      "price": 178.42,
      "timestamp": "2026-01-19T12:00:00.000Z",
      "source": "placeholder"
    },
    // ... more symbols
  ]
}
```

### Error Response Format

All errors return consistent JSON:

```json
{
  "success": false,
  "error": {
    "message": "Symbol parameter is required",
    "code": "VALIDATION_ERROR"
  },
  "meta": {
    "requestId": "550e8400-e29b-41d4-a716-446655440000",
    "timestamp": "2026-01-19T12:00:00.000Z"
  }
}
```

## 🛠️ Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server with hot reload |
| `npm run build` | Compile TypeScript to JavaScript |
| `npm start` | Run production server (requires build first) |
| `npm test` | Run all tests |
| `npm run test:watch` | Run tests in watch mode |
| `npm run test:unit` | Run unit tests only |
| `npm run lint` | Lint TypeScript files |
| `npm run type-check` | Type check without building |

## 🧪 Testing

Run tests:

```bash
npm test
```

Tests include:

- ✅ Health endpoint validation
- ✅ Config sanitization (ensures no secrets leak)
- ✅ Market data sample endpoint
- ✅ Batch endpoint with validation
- ✅ Error handling and 404 routes

## 🔒 Security Best Practices

### API Key Management

✅ **DO:**

- Store API keys in `.env` file
- Use the centralized config module to access keys
- Validate keys on startup
- Never log actual key values

❌ **DON'T:**

- Commit `.env` to version control
- Expose keys in API responses
- Hardcode keys in source code
- Log keys in error messages

### Example: Adding a New API Integration

**Scenario:** You want to integrate a weather API for market analysis.

1. **Add the API key to `.env`:**

```bash
# .env (NEVER commit this file!)
WEATHER_API_KEY=your_actual_weather_api_key_here
```

2. **Update `src/config/index.ts` schema:**

```typescript
const envSchema = z.object({
  // ... existing keys
  WEATHER_API_KEY: z.string().optional(),
});

// Add to parsed config warnings
if (parsed.NODE_ENV === 'development') {
  if (!parsed.WEATHER_API_KEY) {
    console.warn('⚠️  WEATHER_API_KEY is not set. Weather features will not work.');
  }
}
```

3. **Update AppConfig type in `src/types/index.ts`:**

```typescript
export interface AppConfig {
  // ... existing fields
  apiKeys: {
    openai?: string;
    marketData?: string;
    financial?: string;
    weather?: string;  // Add new key
  };
}
```

4. **Update config object in `src/config/index.ts`:**

```typescript
export const config: AppConfig = {
  // ... existing config
  apiKeys: {
    openai: env.OPENAI_API_KEY,
    marketData: env.MARKET_DATA_API_KEY,
    financial: env.FINANCIAL_API_KEY,
    weather: env.WEATHER_API_KEY,  // Add to config
  },
};

// Also update getSanitizedConfig()
export function getSanitizedConfig() {
  return {
    // ... existing fields
    apiKeys: {
      openai: config.apiKeys.openai ? '***configured***' : 'not set',
      marketData: config.apiKeys.marketData ? '***configured***' : 'not set',
      financial: config.apiKeys.financial ? '***configured***' : 'not set',
      weather: config.apiKeys.weather ? '***configured***' : 'not set',
    },
  };
}
```

5. **Create a service in `src/services/`:**

```typescript
// src/services/weatherService.ts
import { config } from '../config';

export class WeatherService {
  async getWeatherData(location: string) {
    const apiKey = config.apiKeys.weather;
    
    if (!apiKey) {
      throw new Error('Weather API key is not configured');
    }

    // Backend calls the weather API using the secret key
    const response = await fetch(
      `https://api.weather.com/v1/location/${location}?apikey=${apiKey}`
    );
    
    return response.json();
  }
}
```

6. **Add route in `src/routes/`:**

```typescript
// src/routes/weather.ts
import { Router } from 'express';
import { WeatherService } from '../services/weatherService';

const router = Router();
const weatherService = new WeatherService();

// iOS app calls this endpoint (no key needed from iOS)
router.get('/:location', async (req, res) => {
  const { location } = req.params;
  const data = await weatherService.getWeatherData(location);
  res.json({ success: true, data });
});

export default router;
```

7. **Mount route in `src/routes/index.ts`:**

```typescript
import weatherRouter from './weather';
router.use('/api/weather', weatherRouter);
```

8. **Update `.env.example` for other developers:**

```bash
# Weather API Key (for weather-based market analysis)
WEATHER_API_KEY=your-weather-api-key-here
```

9. **Test thoroughly:**

```bash
npm run dev
curl http://localhost:8080/api/weather/NYC
```

**Key Point:** The iOS app never sees `WEATHER_API_KEY`. It just calls `/api/weather/NYC` and gets the data back. The backend handles all external API authentication.

## 🐛 Debugging

### View Logs

Development server logs include:

- Request ID (unique per request)
- HTTP method and path
- Response status
- Duration
- Configuration warnings

### Common Issues

**Issue: Port already in use**

```bash
lsof -ti:8080 | xargs kill -9
```

**Issue: iOS app can't connect from physical device**

- Verify your Mac's firewall settings
- Ensure both devices are on same Wi-Fi
- Check the IP address hasn't changed

**Issue: API key not found**

- Verify `.env` file exists and has correct format
- Restart dev server after changing `.env`
- Check for typos in variable names

## 📝 Environment Variables Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `NODE_ENV` | No | `development` | Environment mode (development/production/test) |
| `PORT` | No | `8080` | Server port (8080 recommended for iOS dev) |
| `LOG_LEVEL` | No | `info` | Logging level (debug/info/warn/error) |
| `ENABLE_RATE_LIMITING` | No | `false` | Enable rate limiting (set true in prod) |
| `OPENAI_API_KEY` | No* | - | OpenAI API key for AI forecasting |
| `MARKET_DATA_API_KEY` | No* | - | Market data provider API key |
| `FINANCIAL_API_KEY` | No* | - | Financial data provider API key |

\* Optional in development (will show warning if missing), but required when corresponding features/routes are used.

**Remember:** These keys must NEVER be embedded in the iOS app. The iOS client calls backend endpoints, and the backend uses these keys to call external services.

## 🚢 Production Deployment

### Build for Production

```bash
npm run build
```

Compiled files go to `dist/`.

### Run Production Server

```bash
NODE_ENV=production npm start
```

### Production Checklist

- [ ] Set `NODE_ENV=production`
- [ ] Configure all required API keys
- [ ] Set up proper logging (consider winston/pino)
- [ ] Configure rate limiting (`ENABLE_RATE_LIMITING=true`)
- [ ] Set up monitoring (health checks)
- [ ] Use process manager (PM2, Docker)
- [ ] Configure HTTPS/TLS
- [ ] Set up proper CORS origins for production

## 📚 Project Structure Details

### `/src/config`

Centralized configuration with environment variable validation. Uses Zod for schema validation.

### `/src/middleware`

- `requestLogger.ts`: Adds unique requestId, logs requests
- `errorHandler.ts`: Global error handling with consistent JSON responses

### `/src/services`

Business logic and external API integrations. This is where you add new third-party API calls.

### `/src/routes`

Express route handlers. Keep these thin - delegate to services.

### `/src/types`

TypeScript interfaces and types for type safety.

## 🤝 Contributing

When adding new features:

1. Add types to `src/types/`
2. Implement service in `src/services/`
3. Add routes in `src/routes/`
4. Write tests in `tests/unit/`
5. Update this README

## 📄 License

MIT

---

**Questions?** Check logs, test endpoints with curl, and ensure `.env` is configured correctly.
