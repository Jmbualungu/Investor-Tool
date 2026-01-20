# Company Context API Contract

## Overview

This document defines the API contract for fetching comprehensive company context data. The API is designed to support the enhanced Company Context screen in the DCF flow.

**Status**: Mock implementation (v1.0)  
**Future**: Backend integration via Supabase Edge Functions or REST API  
**Last Updated**: 2026-01-20

---

## Endpoint Options

### Option 1: Supabase Edge Function (Recommended)

```
GET /functions/v1/company-context?ticker={SYMBOL}
```

**Headers**:
- `Authorization: Bearer {anon_key}` (for public read)
- `Content-Type: application/json`

**Query Parameters**:
- `ticker` (required): Stock ticker symbol (e.g., "AAPL", "MSFT")

**Response**: JSON (see schema below)

---

### Option 2: Supabase Database + RPC

**Table**: `company_contexts`

**RPC Function**: `get_company_context(ticker TEXT)`

```sql
CREATE OR REPLACE FUNCTION get_company_context(ticker_symbol TEXT)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN (
    SELECT row_to_json(company_contexts)::jsonb
    FROM company_contexts
    WHERE ticker = UPPER(ticker_symbol)
    LIMIT 1
  );
END;
$$;
```

**Query from Swift**:
```swift
let response = try await supabase
    .rpc("get_company_context", params: ["ticker_symbol": ticker])
    .execute()
```

---

## Response Schema

### CompanyContextModel

```json
{
  "ticker": "AAPL",
  "companyName": "Apple Inc.",
  "sector": "Technology",
  "industry": "Consumer Electronics",
  "tags": ["Innovation", "Platform", "Ecosystem", "Brand"],
  "snapshot": {
    "currentPrice": 185.50,
    "marketCap": 2850000000000,
    "dayChangeAbs": 2.35,
    "dayChangePct": 1.28,
    "description": "Leading consumer technology company with integrated hardware, software, and services ecosystem.",
    "geography": "Global (Americas 40%, Europe 25%, Greater China 20%, Rest of Asia 15%)",
    "businessModel": "Hardware sales + Services subscription + Platform fees",
    "lifecycle": "Mature with growth pockets"
  },
  "heatMap": {
    "columns": ["1Y", "3Y", "5Y"],
    "rows": [
      {
        "id": "growth",
        "title": "Revenue Growth",
        "subtitle": "Historical trajectory",
        "values": [
          { "id": "1y", "score": 0.65, "label": "Med" },
          { "id": "3y", "score": 0.72, "label": "Med-High" },
          { "id": "5y", "score": 0.58, "label": "Med" }
        ]
      },
      {
        "id": "margins",
        "title": "Profit Margins",
        "subtitle": "Operating efficiency",
        "values": [
          { "id": "1y", "score": 0.88, "label": "High" },
          { "id": "3y", "score": 0.85, "label": "High" },
          { "id": "5y", "score": 0.82, "label": "High" }
        ]
      },
      {
        "id": "volatility",
        "title": "Revenue Volatility",
        "subtitle": "Cyclical sensitivity",
        "values": [
          { "id": "1y", "score": 0.35, "label": "Low-Med" },
          { "id": "3y", "score": 0.42, "label": "Med" },
          { "id": "5y", "score": 0.38, "label": "Low-Med" }
        ]
      },
      {
        "id": "cashflow",
        "title": "FCF Conversion",
        "subtitle": "Cash generation power",
        "values": [
          { "id": "1y", "score": 0.92, "label": "High" },
          { "id": "3y", "score": 0.90, "label": "High" },
          { "id": "5y", "score": 0.88, "label": "High" }
        ]
      }
    ]
  },
  "revenueDrivers": [
    {
      "id": "units",
      "title": "Unit Sales Growth",
      "subtitle": "Hardware device volume",
      "sensitivity": "High"
    },
    {
      "id": "asp",
      "title": "Average Selling Price",
      "subtitle": "Premium product mix shift",
      "sensitivity": "Med"
    },
    {
      "id": "services",
      "title": "Services Attach Rate",
      "subtitle": "Subscription penetration",
      "sensitivity": "High"
    }
  ],
  "competitors": [
    {
      "id": "1",
      "name": "Samsung",
      "relativeScale": "Similar",
      "note": "Broader product range"
    },
    {
      "id": "2",
      "name": "Microsoft",
      "relativeScale": "Similar",
      "note": "Ecosystem rival"
    }
  ],
  "risks": [
    {
      "id": "1",
      "title": "Product Cycle Dependency",
      "detail": "Revenue highly tied to annual iPhone refresh cycles and consumer upgrade patterns",
      "impact": "High"
    },
    {
      "id": "2",
      "title": "Regulatory Scrutiny",
      "detail": "App Store policies under antitrust review in multiple jurisdictions",
      "impact": "Med"
    }
  ],
  "framing": "Think of this as a mature platform play with recurring services growth layered on top of cyclical hardware sales. The ecosystem lock-in is the moat — valuation hinges on services penetration and premium pricing power."
}
```

---

## Data Type Definitions

### SnapshotModel
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `currentPrice` | `Double` | Latest stock price | `185.50` |
| `marketCap` | `Double` | Market capitalization in USD | `2850000000000` |
| `dayChangeAbs` | `Double` | Absolute price change today | `2.35` |
| `dayChangePct` | `Double` | Percentage price change today | `1.28` |
| `description` | `String` | 2-3 sentence company description | "Leading consumer tech..." |
| `geography` | `String` | Geographic revenue breakdown | "Global (Americas 40%...)" |
| `businessModel` | `String` | Revenue model description | "Hardware + Services..." |
| `lifecycle` | `String` | Company lifecycle stage | "Mature with growth pockets" |

### HeatMapCell
| Field | Type | Description | Range/Format |
|-------|------|-------------|--------------|
| `id` | `String` | Unique cell identifier | "1y", "3y", "5y" |
| `score` | `Double` | Normalized intensity score | `0.0` to `1.0` |
| `label` | `String` | Human-readable label | "Low", "Med", "High", "Low-Med", etc. |

**Score Mapping**:
- `0.0 - 0.33`: Low
- `0.34 - 0.66`: Med
- `0.67 - 1.0`: High

### DriverModel
| Field | Type | Description | Values |
|-------|------|-------------|--------|
| `sensitivity` | `String` | Revenue impact sensitivity | "Low", "Low-Med", "Med", "Med-High", "High" |

### CompetitorModel
| Field | Type | Description | Values |
|-------|------|-------------|--------|
| `relativeScale` | `String` | Competitor size vs company | "Smaller", "Similar", "Larger" |

### RiskModel
| Field | Type | Description | Values |
|-------|------|-------------|--------|
| `impact` | `String` | Risk impact severity | "Low", "Low-Med", "Med", "Med-High", "High" |

---

## Caching Strategy

### Client-Side (Swift)
- **TTL**: 24 hours (86400 seconds)
- **Storage**: `UserDefaults` or lightweight SQLite
- **Key**: `company_context_{ticker}_{date}`
- **Invalidation**: On earnings events or manual refresh

**Example**:
```swift
struct CachedCompanyContext: Codable {
    let data: CompanyContextModel
    let fetchedAt: Date
    let ticker: String
    
    var isStale: Bool {
        Date().timeIntervalSince(fetchedAt) > 86400 // 24h
    }
}
```

### Server-Side (Supabase)
- **CDN**: Enable Supabase CDN for Edge Functions
- **TTL**: 6 hours (21600 seconds)
- **Purge**: On data updates or scheduled nightly refresh

---

## Data Sources (Future Implementation)

### 1. Company Profile & Fundamentals
**Source**: Financial market data provider (e.g., Polygon.io, Finnhub, Alpha Vantage)
- Ticker symbol
- Company name
- Sector/industry
- Market cap
- Current price
- Description

**Fallback**: Manually curated data for top 500 stocks

### 2. Heat Map Metrics
**Source**: Computed from financial statements
- Revenue growth: YoY revenue CAGR over 1Y, 3Y, 5Y
- Profit margins: Operating margin trends
- Volatility: Revenue standard deviation
- FCF conversion: FCF / Revenue ratio

**Computation**: Run nightly batch job to calculate and store

### 3. Revenue Drivers
**Source**: Industry-specific templates + LLM enhancement
- Base templates per sector (Tech, Financials, Healthcare, etc.)
- LLM (GPT-4) generates custom drivers based on company description
- Curated for consistency

### 4. Competitors
**Source**: Market data provider peers + manual curation
- Provider API: "peers" endpoint
- Manual review for quality
- Store as lookup table

### 5. Risks
**Source**: LLM-generated summaries (optional) or curated templates
- Industry-specific risk templates
- LLM enhances with company-specific context
- Human review for accuracy

### 6. Framing
**Source**: LLM-generated or template-based
- Prompt: "Summarize investment thesis for {ticker} in 2-3 sentences for a DCF model"
- Cached per ticker
- Refreshed quarterly

---

## Security & Access Control

### Public Read Access
- Company context data is non-sensitive (public company info)
- Use Supabase `anon` key for read access
- No user authentication required for this endpoint

### Rate Limiting
- **Client**: Max 10 requests per minute per device
- **Server**: Max 100 requests per minute per API key

### Data Privacy
- No PII stored
- No user-specific data in company context
- Comply with financial data licensing terms

---

## Error Handling

### Error Response Format
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Company data not found for ticker INVALID",
    "details": null
  }
}
```

### Error Codes
| Code | HTTP Status | Description | Client Action |
|------|-------------|-------------|---------------|
| `NOT_FOUND` | 404 | Ticker not in database | Show fallback UI |
| `INVALID_TICKER` | 400 | Invalid ticker format | Prompt user to re-enter |
| `RATE_LIMIT` | 429 | Too many requests | Retry with exponential backoff |
| `INTERNAL_ERROR` | 500 | Server error | Show generic error + retry |

---

## Migration Path

### Phase 1: Mock Provider (Current)
- ✅ `MockCompanyContextProvider` with archetypes
- ✅ No network calls
- ✅ Instant loading for development

### Phase 2: Hybrid Provider
- ⏳ Fetch real price/market cap from market data API
- ⏳ Use mock data for heat map, drivers, risks, framing
- ⏳ Cache responses locally

### Phase 3: Full Backend
- ⏳ Supabase Edge Function or REST API
- ⏳ Computed heat map metrics from financial data
- ⏳ LLM-generated risks and framing
- ⏳ CDN caching

### Phase 4: Advanced Features
- ⏳ Real-time price updates via WebSocket
- ⏳ Earnings event notifications
- ⏳ User-customizable drivers
- ⏳ AI-powered company insights

---

## Testing

### Unit Tests
```swift
func testMockProviderReturnsValidData() async throws {
    let provider = MockCompanyContextProvider()
    let context = try await provider.fetchCompanyContext(ticker: "AAPL")
    
    XCTAssertEqual(context.ticker, "AAPL")
    XCTAssertFalse(context.snapshot.description.isEmpty)
    XCTAssertEqual(context.heatMap.columns.count, 3)
    XCTAssertGreaterThan(context.revenueDrivers.count, 0)
}
```

### Integration Tests
```swift
func testSupabaseProviderFetchesRealData() async throws {
    let provider = SupabaseCompanyContextProvider()
    let context = try await provider.fetchCompanyContext(ticker: "AAPL")
    
    XCTAssertNotNil(context)
    XCTAssertGreaterThan(context.snapshot.currentPrice, 0)
}
```

---

## Changelog

### v1.0 (2026-01-20)
- Initial API contract definition
- Mock provider implementation
- Swift models with Codable support
- Future-proof architecture for backend integration

---

## References

- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Polygon.io Ticker Details](https://polygon.io/docs/stocks/get_v3_reference_tickers__ticker)
- [Financial Modeling Prep API](https://site.financialmodelingprep.com/developer/docs)
