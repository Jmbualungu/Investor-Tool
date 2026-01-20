# Assumptions Template System - Quick Reference

## 🚀 Quick Start

### Access the UI
1. Run app → Accept disclaimer → Settings
2. Tap "Assumptions Templates"
3. Select entity → Select horizon → Adjust sliders → View preview

### File Locations
```
Core/
├── Models/
│   └── AssumptionTemplate.swift          # Data models
└── Services/
    ├── AssumptionTemplateStore.swift     # Storage + seeding
    └── ForecastPreviewEngine.swift       # Preview calculator

Features/Assumptions/
├── HorizonSelectorView.swift             # Horizon picker (1Y/3Y/5Y/10Y)
├── AssumptionRowView.swift               # Slider-first row editor
├── AssumptionsTemplateView.swift         # Main view
└── AssumptionsTemplateViewModel.swift    # ViewModel
```

## 🔑 Key Concepts

### Stable Keys
Every assumption has a permanent `key` field:
```swift
AssumptionItem(key: "revenue_growth", ...)  // Never changes
```
Used for future ticker mapping:
```swift
// Future: Map template to ticker
TickerAssumption(templateKey: "revenue_growth", tickerSymbol: "AAPL", ...)
```

### Sections (7 total)
1. Revenue Drivers
2. Cost & Margins
3. Investment & Capex
4. Working Capital
5. Balance Sheet & Capital Allocation
6. Valuation & Returns
7. Narrative / Re-rating

### Horizons
- **1Y**: Near-term cycle + execution
- **3Y**: Strategy materializes
- **5Y**: Business model durability
- **10Y**: Long-cycle regime change

## 📝 Common Tasks

### Add a New Entity

1. **Add to enum**:
```swift
enum EntityID: String, Codable, CaseIterable {
    case tsla  // Add here
    
    var displayName: String {
        case .tsla: return "Tesla"  // Add here
    }
}
```

2. **Create seed function**:
```swift
private func createTeslaAssumptions(horizon: Horizon) -> [AssumptionItem] {
    return [
        AssumptionItem(
            key: "ev_delivery_growth",
            title: "EV Delivery Growth",
            section: .revenueDrivers,
            valueType: .percent,
            baseValueDouble: horizon.years == 1 ? 30.0 : 20.0,
            usesSlider: true,
            sliderMin: -10.0,
            sliderMax: 50.0,
            sliderStep: 1.0,
            sliderUnitLabel: "%",
            importance: 5,
            driverTag: "Revenue",
            affects: ["Revenue"]
        ),
        // ... more Tesla-specific assumptions
    ]
}
```

3. **Add to switch**:
```swift
private func createTemplateForEntity(_ entityID: EntityID, horizon: Horizon) {
    switch entityID {
    case .tsla:
        items.append(contentsOf: createTeslaAssumptions(horizon: horizon))
    // ...
    }
}
```

4. **Test**: Select "Tesla" in entity picker

### Add a New Core Assumption

Edit `createCoreAssumptions()`:
```swift
AssumptionItem(
    key: "new_assumption",        // Stable key
    title: "New Assumption",      // Display name
    subtitle: "Helper text",      // Optional subtitle
    section: .revenueDrivers,     // Pick section
    valueType: .percent,          // Type
    baseValueDouble: 10.0,        // Default value
    usesSlider: true,             // Enable slider
    sliderMin: 0.0,               // Min bound
    sliderMax: 50.0,              // Max bound
    sliderStep: 0.5,              // Step size
    sliderUnitLabel: "%",         // Unit
    importance: 4,                // 1-5 (4+ shows star)
    driverTag: "Revenue",         // Tag
    affects: ["Revenue", "FCF"]   // What it impacts
)
```

### Modify Slider Bounds

Find assumption in seed data:
```swift
AssumptionItem(
    key: "revenue_growth",
    // ...
    sliderMin: -10.0,    // Change this
    sliderMax: 30.0,     // Change this
    sliderStep: 0.5,     // Change this
    sliderUnitLabel: "%" // Change this
)
```

### Update Preview Calculation

Edit `ForecastPreviewEngine.calculatePreview()`:
```swift
// 1. Extract new assumption
let newAssumption = getAssumptionValue(template: template, key: "new_assumption") ?? 0.0

// 2. Use in calculation
let newMetric = someFormula(newAssumption)

// 3. Return in result
return PreviewResult(
    // ... existing fields
    newMetric: newMetric  // Add new field
)
```

### Add Scenario Support (Bull/Bear)

Data model already supports it:
```swift
AssumptionItem(
    // ...
    baseValueDouble: 10.0,   // Base case
    bullValueDouble: 20.0,   // Bull case
    bearValueDouble: 5.0     // Bear case
)
```

To show in UI, add scenario picker to `AssumptionsTemplateView`.

## 🎨 UI Customization

### Change Horizon Selector

Edit `HorizonSelectorView.swift`:
```swift
// Current: Segmented picker
Picker("Horizon", selection: $selectedHorizon) {
    // ...
}
.pickerStyle(.segmented)

// Future: Replace with custom slider bar
HorizonSliderBar(selectedHorizon: $selectedHorizon)
```

### Customize Row Appearance

Edit `AssumptionRowView.swift`:
```swift
// Change colors
.background(DSColors.surfaceSecondary)  // Row background
.tint(DSColors.accent)                  // Slider color

// Change fonts
.font(DSTypography.body)    // Title
.font(DSTypography.caption) // Subtitle
```

### Add New Section

1. Add to enum:
```swift
enum AssumptionSection: String, Codable, CaseIterable {
    case newSection
    
    var displayName: String {
        case .newSection: return "New Section"
    }
}
```

2. Use in assumptions:
```swift
AssumptionItem(section: .newSection, ...)
```

3. UI automatically shows new section if items exist

## 🔧 Troubleshooting

### "Cannot find type in scope"
→ Add files to Xcode project (see SETUP_ASSUMPTIONS_MODULE.md)

### Templates empty
→ Force delete app, reinstall to trigger seed

### Slider not updating
→ Check `onUpdate: viewModel.handleItemUpdate` callback

### Preview not calculating
→ Check console for errors in `ForecastPreviewEngine`

### Data not persisting
→ Verify SwiftData models in `ForecastAIApp.modelContainer(for: [...])`

## 📊 Sample Slider Bounds

Reference for creating new assumptions:

| Metric | Min | Max | Step | Unit |
|--------|-----|-----|------|------|
| Revenue growth | -10 | 30 | 0.5 | % |
| Operating margin | 0 | 40 | 0.5 | % |
| Capex % revenue | 0 | 20 | 0.25 | % |
| Terminal P/E | 5 | 40 | 0.5 | x |
| Discount rate | 6 | 18 | 0.25 | % |
| Buyback % | -3 | 5 | 0.25 | % |
| Inventory turns | 2 | 25 | 0.5 | x |
| Days | 30 | 180 | 5 | days |
| Score (0-100) | 0 | 100 | 5 | none |

## 🚀 Future Integration: Ticker Mapping

### Template → Ticker Flow

```swift
// 1. User selects ticker
let ticker = "AAPL"

// 2. Load relevant template
let template = store.getTemplate(entityID: .aapl, horizon: .fiveYear)

// 3. Fetch market data
let marketData = marketDataService.fetch(ticker)

// 4. Map template keys to market values
for item in template.items {
    switch item.key {
    case "revenue_growth":
        item.baseValueDouble = marketData.revenueCAGR(years: 5)
    case "operating_margin":
        item.baseValueDouble = marketData.operatingMargin
    case "starting_share_price":
        item.baseValueDouble = marketData.currentPrice
    // ... map other keys
    }
}

// 5. User can override any value
// 6. Save as TickerProject
let project = TickerProject(
    ticker: ticker,
    templateEntityID: .aapl,
    horizon: .fiveYear,
    assumptions: /* mapped items */
)
```

## 🎯 Testing Checklist

- [ ] Select each entity (6 total)
- [ ] Switch between horizons (4 per entity)
- [ ] Adjust sliders (smooth movement)
- [ ] View preview updates (recalculates)
- [ ] Tap info button (detail sheet)
- [ ] Collapse/expand sections (animations)
- [ ] Reset template (restores defaults)
- [ ] Restart app (data persists)

## 📚 Related Docs

- **IMPLEMENTATION_SUMMARY.md** - What was built
- **README_Assumptions.md** - Architecture deep-dive
- **SETUP_ASSUMPTIONS_MODULE.md** - Xcode integration guide

## 💡 Tips

1. **Slider bounds**: Choose ranges that cover 95% of realistic scenarios
2. **Step size**: Smaller steps (0.25) for critical assumptions, larger (1.0) for less sensitive
3. **Importance**: Use 5 for critical drivers, 3 for moderate, 1 for minor
4. **Keys**: Use snake_case, be descriptive, never change
5. **Sections**: Group related assumptions for better UX
6. **Notes**: Use for enum options ("Options: Low, Medium, High")

## 🔐 Best Practices

✅ **DO**:
- Use stable keys that never change
- Set realistic slider bounds
- Document entity-specific assumptions
- Test across all horizons
- Validate preview calculations

❌ **DON'T**:
- Change existing keys (breaks ticker mapping)
- Use overly wide slider ranges (confusing)
- Forget to set importance
- Skip notes on enum assumptions
- Hardcode values (use seed functions)

---

**Quick Ref**: Keep this handy when extending the system  
**Status**: Production-ready template module  
**Questions**: See full docs in README_Assumptions.md
