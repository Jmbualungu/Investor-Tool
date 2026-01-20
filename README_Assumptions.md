# Assumptions Template System

## Overview

The Assumptions Template module provides a comprehensive, slider-first UI for defining and editing financial forecasting assumptions. This is a **template-based** system using **sample data only** - no real market data or external APIs are involved.

## Architecture

### Core Concept

The system separates **templates** (generic industry/company patterns) from **projects** (ticker-specific forecasts). Templates serve as starting points that can later be attached to real tickers when market data integration is added.

```
Template Layer (Current)           Project Layer (Future)
├── EntityID (auto_industry, aapl) → Ticker Symbol (AAPL, TSLA)
├── Sample assumptions             → Ticker-specific assumptions
└── Illustrative values            └── Real market data mapping
```

### Data Model Hierarchy

```
EntityAssumptionsTemplate
├── entityID: EntityID (e.g., aapl, nvda)
├── horizon: Horizon (1Y, 3Y, 5Y, 10Y)
└── items: [AssumptionItem]
    ├── key: String (stable identifier)
    ├── title: String
    ├── section: AssumptionSection
    ├── valueType: ValueType
    ├── baseValueDouble: Double?
    ├── sliderMin/Max/Step: Double?
    ├── importance: Int (1-5)
    ├── driverTag: String
    ├── affects: [String]
    └── notes: String?
```

## Key Design Decisions

### 1. Stable Keys for Ticker Mapping

Each `AssumptionItem` has a **stable `key`** field (e.g., `"revenue_growth"`, `"operating_margin"`) that never changes. When integrating with real ticker data:

```swift
// Template assumption
AssumptionItem(key: "revenue_growth", baseValueDouble: 8.0, ...)

// Future: Ticker-specific mapping
TickerAssumption(
    templateKey: "revenue_growth",
    tickerSymbol: "AAPL",
    marketValue: marketDataService.getRevenueCAGR("AAPL"), // Real data
    userOverride: 10.0  // User can override market data
)
```

### 2. Slider-First UI

Assumptions with numeric values use **sliders as the primary input** with thoughtfully configured bounds:

- **Revenue growth**: -10% to +30%, step 0.5%
- **Operating margin**: 0% to 40%, step 0.5%
- **Terminal P/E**: 5x to 40x, step 0.5x
- **Discount rate**: 6% to 18%, step 0.25%

Text fields are only used for non-numeric assumptions (enum choices, notes).

### 3. Horizon-Specific Values

Each entity has **4 separate templates** (1Y, 3Y, 5Y, 10Y) with horizon-appropriate values:

- **1Y**: Near-term cycle + execution risk
- **3Y**: Strategy begins to materialize
- **5Y**: Business model durability + reinvestment payoff
- **10Y**: Long-cycle regime change

### 4. Sections for Organization

Assumptions are organized into **7 sections**:

1. **Revenue Drivers**: Growth, volume, price/ASP, mix
2. **Cost & Margins**: Gross margin, operating margin, R&D
3. **Investment & Capex**: Capex intensity, maintenance split
4. **Working Capital**: NWC change, inventory turns
5. **Balance Sheet & Capital Allocation**: Net debt, buybacks, SBC dilution
6. **Valuation & Returns**: Starting price, terminal multiple, discount rate, FCF conversion
7. **Narrative / Re-rating**: Regulatory risk, competitive intensity

### 5. Preview Impact Calculator

A lightweight **ForecastPreviewEngine** computes illustrative outputs:

```
Inputs (from assumptions):
- Revenue growth, operating margin, FCF conversion rate
- Buyback %, SBC dilution, starting price, terminal P/E

Outputs (illustrative):
- Revenue Index (compound growth)
- FCF Margin Estimate (op margin × conversion)
- FCF Index (revenue × margin)
- Share Count Change (net buybacks - dilution)
- Implied Share Price (simplified terminal value)
- Implied Total Return (vs starting price)
```

**Important**: This is NOT a full DCF model - it's a simplified demonstration showing how assumptions affect outcomes. Will be replaced with proper projection engine later.

## Storage

Uses **SwiftData** (iOS 17+) for local-first storage:

```swift
@Model
final class EntityAssumptionsTemplate { ... }

@Model
final class AssumptionItem { ... }
```

Templates are **seeded on first launch** with sample data for 6 entities × 4 horizons = 24 templates.

## Entity-Specific Assumptions

Each entity has core assumptions plus unique industry drivers:

### Auto Industry
- SAAR / unit growth
- EV penetration %
- Incentives % of sales
- Dealer inventory days
- Warranty provision %

### NVIDIA
- Data center growth %
- GPU ASP trend %
- Export control severity
- Custom silicon substitution risk

### Apple
- iPhone unit growth & ASP
- Installed base growth
- Services ARPU growth
- Upgrade cycle length
- App Store regulation risk

### GE (Industrial/Aerospace)
- Book-to-bill ratio
- Backlog growth & conversion
- Aftermarket mix %
- Quality/certification risk

### Costco
- Membership growth & renewal rate
- Executive penetration %
- Comp sales growth
- New warehouse openings

### McDonald's
- Same-store sales growth
- Traffic vs ticket breakdown
- Digital mix %
- Remodel penetration %
- Franchisee health score

## UI Components

### HorizonSelectorView
Isolated component for horizon selection (1Y/3Y/5Y/10Y). Currently uses segmented picker - can be swapped with sliding bar UI later without affecting other components.

### AssumptionRowView
Row component supporting:
- **Slider editor** (for numeric assumptions with bounds)
- **Picker editor** (for enum choices like Low/Medium/High)
- **Text editor** (fallback for open-ended text)
- **Info button** → Detail sheet with metadata

### AssumptionsTemplateView
Main view with:
- Entity picker (dropdown menu)
- Horizon selector
- "Key Assumptions" area (top 6 by importance)
- Collapsible sections
- Preview impact panel
- Reset & duplicate actions

## Future Integration: Ticker-Based Projects

When adding real ticker support:

### 1. Market Data Service

```swift
protocol MarketDataService {
    func fetchHistoricals(symbol: String) -> HistoricalData
    func getRevenueCAGR(symbol: String, years: Int) -> Double
    func getMargins(symbol: String) -> Margins
    func getCurrentPrice(symbol: String) -> Double
    func getSharesOutstanding(symbol: String) -> Double
}
```

### 2. Ticker Assumption Mapping

```swift
struct TickerAssumption: Codable {
    var templateKey: String  // Maps to AssumptionItem.key
    var tickerSymbol: String
    var marketValue: Double?  // From market data service
    var userOverride: Double?  // User can override
    var lastUpdated: Date
    
    var effectiveValue: Double {
        return userOverride ?? marketValue ?? 0
    }
}

struct TickerProject: Codable {
    var id: UUID
    var tickerSymbol: String
    var templateEntityID: EntityID?  // Which template was used
    var horizon: Horizon
    var assumptions: [TickerAssumption]
}
```

### 3. Template → Ticker Flow

```
User Action: "Create forecast for AAPL"
↓
1. Select template (Apple template)
2. Load template assumptions
3. Fetch real market data for AAPL
4. Map assumptions:
   - revenue_growth: Use last 5Y CAGR from market data
   - operating_margin: Use TTM margin from market data
   - starting_share_price: Use current quote
   - User can override any value via slider
5. Create TickerProject
6. Run full projection engine (not preview engine)
7. Generate real DCF valuation
```

### 4. Assumption Key Mapping Table

| Template Key | Market Data Source | Override Priority |
|--------------|-------------------|------------------|
| `revenue_growth` | Historical CAGR (configurable years) | User override |
| `operating_margin` | TTM or average margin | User override |
| `gross_margin` | TTM gross margin | User override |
| `starting_share_price` | Current quote | Auto-updated |
| `starting_shares_outstanding` | Latest filing | Auto-updated |
| `capex_pct_revenue` | Historical avg capex / revenue | User override |
| `net_debt_ebitda` | Latest balance sheet | Auto-updated |
| `terminal_pe_multiple` | Sector median or user choice | User override |
| `discount_rate` | WACC or user choice | User override |

### 5. Benefits of Template System

✅ **Consistency**: All forecasts start from proven industry patterns  
✅ **Speed**: Pre-configured sliders with sensible bounds  
✅ **Education**: Users learn which assumptions matter most  
✅ **Flexibility**: Templates are starting points, fully customizable  
✅ **No API lock-in**: Template layer works offline; ticker layer adds data  

## Testing & Development

### Running the Module

1. App automatically seeds templates on first launch
2. Navigate to AssumptionsTemplateView
3. Select entity (e.g., "Apple")
4. Select horizon (e.g., "5Y")
5. Adjust assumptions via sliders
6. View preview impact at bottom
7. Reset to template defaults if needed

### Sample Data Quality

All values are **illustrative placeholders** designed to:
- Demonstrate slider bounds and stepping
- Show how assumptions interact
- Exercise the preview calculator
- NOT represent real forecasts or investment advice

### Adding New Entities

To add a new entity (e.g., "Tesla"):

1. Add case to `EntityID` enum
2. Implement `createTeslaAssumptions(horizon:)` in `AssumptionTemplateStore`
3. Define core + Tesla-specific assumptions
4. Seed will automatically include all horizons
5. UI will automatically show new entity in picker

### Adding New Assumptions

To add an assumption across all entities:

1. Add to `createCoreAssumptions()` for shared assumptions, OR
2. Add to entity-specific function for unique assumptions
3. Define stable `key`, slider bounds, section, importance
4. Update `ForecastPreviewEngine` if it affects calculations
5. Re-seed templates (or just add to existing via migration)

## Performance

- **Storage**: SwiftData with local SQLite
- **Load time**: Templates are small (~30 items × 24 templates = ~720 items total)
- **Preview calc**: O(n) scan through items, sub-millisecond
- **UI updates**: SwiftUI observation for reactive updates

## Accessibility

- All sliders have VoiceOver labels with values
- Segmented picker for horizons (standard iOS control)
- Collapsible sections reduce cognitive load
- High importance indicators (star icon) for key assumptions

## Future Enhancements

1. **Scenarios**: Bull/bear/base tabs (model already has fields)
2. **Charts**: Visualize assumption impacts over time
3. **Comparison**: Side-by-side entity/horizon comparison
4. **Export**: CSV/JSON export of assumptions
5. **Sharing**: iCloud sync of custom templates
6. **AI Assist**: Suggest assumption ranges based on sector/historical data

## Notes

- This is a **local-first** module - no network, no external dependencies
- Templates are **samples** - not investment advice
- Slider bounds are **illustrative** - users can type larger values in detail view
- Preview engine is **simplified** - real DCF engine coming later
- Keys are **stable** - safe for long-term storage and ticker mapping

---

**Status**: ✅ Template module complete and ready for ticker integration  
**Next Step**: Build market data service + ticker project layer  
**Timeline**: Template system is production-ready; ticker layer is future work
