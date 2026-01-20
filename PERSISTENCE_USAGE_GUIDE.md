# SwiftData Persistence Usage Guide

## Overview

Local persistence has been successfully added to Investor Tool using SwiftData (iOS 17+). The implementation stores forecasts and scenarios with JSON-serialized assumptions and outputs, providing a clean migration path to Supabase later.

## What Was Added

### 1. SwiftData Models (`PersistenceModels.swift`)

```swift
@Model
final class SavedForecast {
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    
    var ticker: String
    var companyName: String?
    var horizonYears: Int
    var style: String
    var objective: String
    
    // JSON strings for flexibility
    var assumptionsJSON: String
    var outputsJSON: String
    
    // Quick access fields
    var intrinsicValue: Double
    var upsidePercent: Double
    var cagrPercent: Double
}

@Model
final class SavedScenario {
    var id: UUID
    var createdAt: Date
    var name: String
    var ticker: String
    var assumptionsJSON: String
}
```

### 2. Codable Payloads (`ForecastPayloads.swift`)

Structures for JSON serialization:
- `AssumptionsPayload`: Revenue drivers, operating, valuation, and lens
- `OutputsPayload`: All calculated outputs (intrinsic value, upside, CAGR, etc.)
- `RevenueDriverCodable`: Serializable revenue driver
- `LensCodable`: Serializable investment lens

### 3. DCFFlowState Extensions

Added methods to `DCFFlowState`:
- `makeAssumptionsPayload()` → AssumptionsPayload
- `makeOutputsPayload()` → OutputsPayload
- `assumptionsJSON()` → String
- `outputsJSON()` → String

### 4. Persistence Service (`ForecastPersistenceService.swift`)

Convenience methods for CRUD operations:
- `saveForecast(from:to:)`
- `updateForecast(_:from:to:)`
- `saveScenario(name:from:to:)`
- `fetchForecasts(from:)`
- `fetchForecasts(for:from:)`
- `fetchScenarios(for:from:)`
- `deleteForecast(_:from:)`
- `deleteScenario(_:from:)`

## Usage Examples

### Save a Forecast

```swift
import SwiftUI
import SwiftData

struct ValuationResultsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var flowState: DCFFlowState
    
    var body: some View {
        VStack {
            // ... your results UI ...
            
            Button("Save Forecast") {
                Task {
                    do {
                        try ForecastPersistenceService.saveForecast(
                            from: flowState,
                            to: modelContext
                        )
                        // Show success message
                    } catch {
                        // Handle error
                        print("Save failed: \(error)")
                    }
                }
            }
        }
    }
}
```

### List Saved Forecasts

```swift
struct SavedForecastsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedForecast.updatedAt, order: .reverse) 
    private var forecasts: [SavedForecast]
    
    var body: some View {
        List(forecasts) { forecast in
            VStack(alignment: .leading) {
                Text(forecast.ticker)
                    .font(.headline)
                Text(forecast.companyName ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text("Intrinsic: $\(forecast.intrinsicValue, specifier: "%.2f")")
                    Spacer()
                    Text("Upside: \(forecast.upsidePercent, specifier: "%.1f")%")
                }
                .font(.caption)
            }
        }
    }
}
```

### Save a Scenario

```swift
Button("Save as Scenario") {
    Task {
        do {
            try ForecastPersistenceService.saveScenario(
                name: "Bull Case",
                from: flowState,
                to: modelContext
            )
        } catch {
            print("Save scenario failed: \(error)")
        }
    }
}
```

### Load a Forecast

```swift
// To load assumptions from saved JSON, you'll need to add a restore method
// to DCFFlowState (not yet implemented):

extension DCFFlowState {
    func restoreFromForecast(_ forecast: SavedForecast) throws {
        guard let assumptionsData = forecast.assumptionsJSON.data(using: .utf8) else {
            throw PersistenceError.invalidJSON
        }
        
        let decoder = JSONDecoder()
        let payload = try decoder.decode(AssumptionsPayload.self, from: assumptionsData)
        
        // Restore state from payload
        self.revenueDrivers = payload.revenueDrivers.map { codable in
            RevenueDriver(
                id: codable.id,
                title: codable.title,
                subtitle: codable.subtitle,
                unit: UnitType(rawValue: codable.unit) ?? .percent,
                value: codable.value,
                min: codable.min,
                max: codable.max,
                step: codable.step,
                impactsRevenue: codable.impactsRevenue
            )
        }
        self.operatingAssumptions = payload.operating
        self.valuationAssumptions = payload.valuation
        // ... restore lens ...
    }
}
```

## Model Container Setup

The app is already configured in `ForecastAIApp.swift`:

```swift
@main
struct ForecastAIApp: App {
    var body: some Scene {
        WindowGroup {
            DiagnosticsRootView()
        }
        .modelContainer(for: [
            AppItem.self,
            EntityAssumptionsTemplate.self,
            AssumptionItem.self,
            SavedForecast.self,  // ✅ Added
            SavedScenario.self   // ✅ Added
        ], inMemory: false)
    }
}
```

## Migration Path to Supabase

The JSON storage strategy makes backend migration straightforward:

1. Create Supabase tables matching the SwiftData models
2. Add `sync_status` and `last_synced` fields
3. Upload `assumptionsJSON` and `outputsJSON` as-is
4. Parse JSON server-side if needed for filtering/analytics
5. Keep local SwiftData as offline cache

## Build Status

✅ **Build Successful**
- All files compiled without errors
- App runs in simulator
- SwiftData models registered correctly

## Files Added/Modified

### Added:
- `Core/Models/PersistenceModels.swift`
- `Core/Models/ForecastPayloads.swift`
- `Core/Services/ForecastPersistenceService.swift`

### Modified:
- `Core/Models/DCFFlowState.swift` (added JSON helpers)
- `App/ForecastAIApp.swift` (added models to container)

## Next Steps

1. **Add UI for saved forecasts** - Create a list view to browse saved forecasts
2. **Implement restore functionality** - Add method to restore DCFFlowState from saved forecast
3. **Add scenario management** - UI to save/load/compare scenarios
4. **Export functionality** - Allow exporting forecasts as JSON files
5. **Search and filter** - Add search by ticker, date range, etc.

## Testing

To verify the persistence layer works:

1. Run the app in simulator
2. Complete a DCF analysis
3. Call `ForecastPersistenceService.saveForecast()` 
4. Query forecasts using SwiftData `@Query`
5. Verify data persists across app launches

## Notes

- JSON is stored with `.sortedKeys` for deterministic output
- All dates use ISO 8601 format
- UUIDs ensure uniqueness
- `inMemory: false` ensures data persists to disk
- Ready for CloudKit sync by adding `@Attribute(.cloudSyncable)`
