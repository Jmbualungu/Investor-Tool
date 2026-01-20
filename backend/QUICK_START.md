# Backend Quick Start Guide

## TL;DR - Get Running in 60 Seconds

```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your API keys (optional for initial testing)
npm run dev
```

Server starts at: **http://localhost:8080**

Test it:
```bash
curl http://localhost:8080/health
```

---

## iOS Integration

### Simulator
```swift
let baseURL = "http://127.0.0.1:8080"
```

### Physical Device
```swift
// Find your Mac IP: ifconfig | grep "inet " | grep -v 127.0.0.1
let baseURL = "http://192.168.1.X:8080"  // Replace X with your IP
```

### Info.plist (Dev Only)
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

⚠️ **Remove before App Store submission!**

---

## API Endpoints

- `GET /health` - Health check (always works)
- `GET /health/config` - View config (sanitized)
- `GET /api/market/sample?symbol=AAPL` - Sample data
- `POST /api/market/batch` - Batch symbols

---

## Environment Variables

Edit `.env`:

```bash
# Required
PORT=8080
NODE_ENV=development

# Optional (add when needed)
OPENAI_API_KEY=sk-proj-...
MARKET_DATA_API_KEY=...
FINANCIAL_API_KEY=...
```

---

## Architecture Rule 🔒

**NEVER put API keys in iOS app!**

```
iOS App → Backend → External APIs
          (keys here only)
```

iOS calls backend endpoints.
Backend calls OpenAI/market data APIs.
iOS never sees the keys.

---

## Production Checklist

Before deploying:

- [ ] Get real API keys and add to production `.env`
- [ ] Deploy to Railway/Heroku/AWS with HTTPS
- [ ] Update iOS baseURL to `https://your-domain.com`
- [ ] Remove ATS exceptions from iOS Info.plist
- [ ] Set `ENABLE_RATE_LIMITING=true`
- [ ] Configure production CORS origins
- [ ] Set up monitoring

---

## Common Issues

**Port already in use?**
```bash
lsof -ti:8080 | xargs kill -9
```

**iOS can't connect from device?**
- Check both on same Wi-Fi
- Verify Mac IP hasn't changed
- Check Mac firewall settings

**API key not found?**
- Restart dev server after changing `.env`
- Check for typos in variable names

---

## More Info

- Full docs: `backend/README.md`
- Implementation details: `backend/IMPLEMENTATION_COMPLETE.md`
- Example env: `backend/.env.example`
