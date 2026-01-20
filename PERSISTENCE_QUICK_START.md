# SwiftData Persistence - Quick Start

## ✅ Implementation Complete

Local persistence using SwiftData is now fully integrated and tested.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                             │
│  (SwiftUI Views with @Query and @Environment(\.modelContext))│
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  ForecastPersistenceService                  │
│         (Convenience methods for CRUD operations)            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      DCFFlowState                            │
│   makeAssumptionsPayload() → assumptionsJSON()              │
│   makeOutputsPayload()     → outputsJSON()                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Codable Payloads                           │
│  AssumptionsPayload | OutputsPayload | RevenueDriverCodable │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     SwiftData Models                         │
│         SavedForecast | SavedScenario                       │
│    (stored as JSON strings for Supabase migration)          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        Disk Storage                          │
│                  (SQLite via SwiftData)                      │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow: Save

```
User completes DCF
       │
       ▼
DCFFlowState.assumptionsJSON()  ───┐
DCFFlowState.outputsJSON()         │
       │                           │
       ▼                           │
Create SavedForecast               │ JSON Strings
   ticker: "AAPL"                  │ for Supabase
   assumptionsJSON: "{...}"  ◄─────┘ migration
   outputsJSON: "{...}"
   intrinsicValue: 185.50
       │
       ▼
ForecastPersistenceService.saveForecast()
       │
       ▼
SwiftData ModelContext.insert()
       │
       ▼
Saved to disk ✅
```

## Data Flow: Load

```
User opens Saved Forecasts
       │
       ▼
@Query SwiftData
       │
       ▼
List of SavedForecast
   - ticker
   - intrinsicValue
   - updatedAt
       │
       ▼
User taps forecast
       │
       ▼
Deserialize assumptionsJSON
       │
       ▼
Restore DCFFlowState
       │
       ▼
Continue editing ✅
```

## 5-Minute Integration

### 1. Save a Forecast (Add to Results Screen)

```swift
import SwiftData

struct ValuationResultsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var flowState: DCFFlowState
    @State private var showSaveSuccess = false
    
    var body: some View {
        VStack {
            // Your existing results UI
            
            Button("Save Forecast") {
                saveCurrentForecast()
            }
            .buttonStyle(.borderedProminent)
        }
        .alert("Forecast Saved", isPresented: $showSaveSuccess) {
            Button("OK") { }
        }
    }
    
    private func saveCurrentForecast() {
        do {
            try ForecastPersistenceService.saveForecast(
                from: flowState,
                to: modelContext
            )
            showSaveSuccess = true
        } catch {
            print("Save failed: \(error)")
        }
    }
}
```

### 2. View Saved Forecasts (New Screen)

```swift
import SwiftData

struct SavedForecastsView: View {
    @Query(sort: \SavedForecast.updatedAt, order: .reverse)
    private var forecasts: [SavedForecast]
    
    var body: some View {
        List(forecasts) { forecast in
            ForecastRow(forecast: forecast)
        }
        .navigationTitle("Saved Forecasts")
    }
}

struct ForecastRow: View {
    let forecast: SavedForecast
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(forecast.ticker)
                    .font(.headline)
                Spacer()
                Text(forecast.updatedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let name = forecast.companyName {
                Text(name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Intrinsic Value")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("$\(forecast.intrinsicValue, specifier: "%.2f")")
                        .font(.body.weight(.medium))
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Upside")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(forecast.upsidePercent, specifier: "%.1f")%")
                        .font(.body.weight(.medium))
                        .foregroundStyle(
                            forecast.upsidePercent >= 0 ? .green : .red
                        )
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("CAGR")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(forecast.cagrPercent, specifier: "%.1f")%")
                        .font(.body.weight(.medium))
                }
            }
        }
        .padding(.vertical, 4)
    }
}
```

### 3. Add to Navigation (in HomeView or TabView)

```swift
NavigationLink("Saved Forecasts") {
    SavedForecastsView()
}
```

## Key Features

✅ **Automatic Persistence** - SwiftData handles all storage  
✅ **Type-Safe** - Codable payloads ensure data integrity  
✅ **Future-Proof** - JSON storage enables easy Supabase migration  
✅ **No Backend** - Pure local storage, no network calls  
✅ **Offline-First** - Works without internet  

## What's Stored

### Per Forecast:
- Ticker symbol & company name
- Investment lens (horizon, style, objective)
- Complete assumptions (as JSON)
- Complete outputs (as JSON)
- Quick-access fields (intrinsic value, upside %, CAGR)
- Created/updated timestamps

### Per Scenario:
- Name (e.g., "Bull Case", "Conservative")
- Ticker
- Complete assumptions (as JSON)
- Created timestamp

## JSON Example

### Assumptions JSON:
```json
{
  "lens": {
    "horizonYears": 5,
    "objective": "appreciation",
    "style": "base"
  },
  "operating": {
    "capexPercent": 4.0,
    "grossMargin": 55.0,
    "operatingMargin": 22.0,
    "taxRate": 21.0,
    "workingCapitalPercent": 1.0
  },
  "revenueDrivers": [
    {
      "id": "...",
      "impactsRevenue": true,
      "max": 30.0,
      "min": -10.0,
      "step": 0.5,
      "subtitle": "YoY growth in subscribers",
      "title": "User Growth",
      "unit": "percent",
      "value": 12.5
    }
  ],
  "valuation": {
    "discountRate": 9.0,
    "exitMultiple": null,
    "terminalGrowth": 2.5,
    "terminalMethod": "Perpetuity Growth"
  }
}
```

## Migration to Supabase (Later)

When ready:

1. **Create table in Supabase**
2. **Upload JSON as-is** - no parsing needed
3. **Add sync status** - track what's synced
4. **Keep local as cache** - offline-first approach

No code changes needed to data structures!

## Build Status

✅ Compiles without errors  
✅ Runs in simulator  
✅ No linter warnings  
✅ All tests pass  

## Files to Know

- `PersistenceModels.swift` - SwiftData @Model classes
- `ForecastPayloads.swift` - Codable structs for JSON
- `ForecastPersistenceService.swift` - Save/load/delete methods
- `DCFFlowState.swift` - JSON serialization methods
- `ForecastAIApp.swift` - Model container setup

## Full Documentation

See `PERSISTENCE_USAGE_GUIDE.md` for complete examples and patterns.

---

**Ready to use!** Just add the UI components when you're ready to expose the persistence features to users.
