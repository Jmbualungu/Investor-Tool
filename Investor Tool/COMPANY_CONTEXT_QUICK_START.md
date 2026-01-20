# Company Context - Quick Start Guide

## 🎯 What You Got

A completely upgraded Company Context screen with:
- **Robinhood-style UI** with 6 comprehensive sections
- **Mock data provider** with 5 realistic archetypes
- **Heat map visualization** for multi-dimensional analysis
- **Future-proof architecture** ready for backend integration

## ⚡️ Run It Now

### Option 1: Xcode (Recommended)

1. Open the project:
   ```bash
   cd "/Users/jamesmbualungu/Desktop/Coding/Investor Tool"
   open "Investor Tool.xcodeproj"
   ```

2. Select a simulator (iPhone 15 Pro recommended)

3. Press ⌘R to run

4. Navigate to DCF flow → Search ticker → Select any ticker

### Option 2: Command Line

```bash
cd "/Users/jamesmbualungu/Desktop/Coding/Investor Tool"

# Build
xcodebuild -project "Investor Tool.xcodeproj" \
  -scheme "Investor Tool" \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  build

# Then open in Xcode to run
open "Investor Tool.xcodeproj"
```

## 🧪 Test Different Archetypes

Each ticker shows different data based on its archetype:

### Consumer Tech (AAPL, TSLA, NVDA)
```
Characteristics:
- High profit margins (82-88%)
- Med-high revenue growth
- Platform/ecosystem model
- Low-med volatility
- High FCF conversion

Try: AAPL
```

### Enterprise SaaS (MSFT, CRM, NOW, ADBE)
```
Characteristics:
- Recurring revenue model
- High margins (75-82%)
- Low volatility
- Cloud/subscription focus
- High retention rates

Try: MSFT
```

### Commerce + Cloud (AMZN, GOOGL, META, NFLX)
```
Characteristics:
- Mixed business model
- Med margins (48-55%)
- Diversified revenue streams
- Med volatility
- Advertising + platform

Try: AMZN
```

### Cyclical Manufacturing (F, BA, CAT, DE)
```
Characteristics:
- Capital intensive
- Low-med margins (30-38%)
- High volatility
- Cyclical demand
- Legacy cost structure

Try: F
```

### Generic (Any Other Ticker)
```
Characteristics:
- Balanced metrics
- Med growth/margins/volatility
- Diversified operations
- Fallback archetype

Try: XYZ
```

## 📊 What to Look For

### 1. Snapshot Hero Card
- ✅ Ticker symbol (large, bold)
- ✅ Current price ($185.50)
- ✅ Day change (+$2.35 / +1.28%)
- ✅ Market cap badge ($2.8T)
- ✅ Lifecycle badge (e.g., "Mature with growth pockets")
- ✅ Tags (horizontal scroll: Innovation, Platform, Ecosystem, Brand)
- ✅ Company description (2-3 sentences)
- ✅ Geography breakdown
- ✅ Business model description

### 2. Heat Map Card
- ✅ "At a glance" header
- ✅ Column headers (1Y, 3Y, 5Y)
- ✅ 4 rows:
  - Revenue Growth (historical trajectory)
  - Profit Margins (operating efficiency)
  - Revenue Volatility (cyclical sensitivity)
  - FCF Conversion (cash generation power)
- ✅ Cells with labels (Low, Med, High, etc.)
- ✅ Subtle intensity gradients (not bright colors)

### 3. Revenue & Value Drivers Card
- ✅ 3-5 driver cards
- ✅ Each has: title, subtitle, sensitivity badge
- ✅ Color-coded badges:
  - High → Red/Negative
  - Med → Orange/Warning
  - Low → Gray/Neutral

### 4. Competitive Landscape Card
- ✅ Horizontal scroll of competitor chips
- ✅ Each chip: name, relative scale, optional note
- ✅ Scroll gesture works smoothly

### 5. Risk & Sensitivity Flags Card
- ✅ 3-4 risk rows
- ✅ Each has: title, detail, impact badge
- ✅ Expandable text areas
- ✅ Color-coded impact levels

### 6. Framing Card
- ✅ Lightbulb icon
- ✅ "How to think about this company" header
- ✅ 2-3 sentence investment thesis
- ✅ Accent-tinted background

### 7. Bottom CTA Bar
- ✅ "Set Investment Lens →" button
- ✅ Ultra-thin material background
- ✅ Haptic feedback on tap
- ✅ Navigates to Investment Lens screen

## 🎨 Design Verification

### Dark Mode
1. Swipe down from top-right → Control Center
2. Toggle Dark Mode
3. Verify:
   - Text is readable
   - Heat map cells are subtle (not bright)
   - Badges have proper contrast
   - No harsh white backgrounds

### Scrolling
1. Scroll through all sections
2. Verify:
   - Smooth 60fps scrolling
   - Tags scroll horizontally
   - Competitor chips scroll horizontally
   - Bottom bar stays fixed

### Responsive Layout
1. Rotate device to landscape
2. Verify:
   - Heat map cells adjust width
   - Text wraps properly
   - No clipping or overflow

## 🔍 Testing Edge Cases

### Loading State
The view should show a spinner for ~0.3 seconds while "loading". This is a simulated delay.

### Error State
To test error handling, temporarily modify `MockCompanyContextProvider.swift`:

```swift
func fetchCompanyContext(ticker: String) async throws -> CompanyContextModel {
    throw CompanyContextError.notFound
}
```

Should show:
- Error icon
- "Failed to load context" message
- Retry button

### Empty/Unknown Tickers
Any ticker not in the archetype map (AAPL, MSFT, AMZN, F, etc.) will fall back to the Generic archetype.

## 🚀 Next Steps (Optional)

### Add More Archetypes
Edit `MockCompanyContextProvider.swift` and add cases to `determineArchetype()`:

```swift
case "NFLX", "DIS", "PARA":
    return .streaming
```

Then implement `generateStreamingContext()` following the existing patterns.

### Test with Real Navigation
1. Start from DCF flow home
2. Search for a ticker
3. Select ticker → Company Context loads
4. Tap "Set Investment Lens" → Should navigate to next screen
5. Verify `DCFFlowState` preserves ticker selection

### Customize Mock Data
Edit the archetype generators in `MockCompanyContextProvider.swift` to adjust:
- Heat map scores
- Driver lists
- Competitor names
- Risk descriptions
- Framing text

## 📚 Documentation

- **Implementation Details**: See `COMPANY_CONTEXT_UPGRADE_SUMMARY.md`
- **API Contract**: See `backend/company-context-api-contract.md`
- **Code**: All files in `Features/DCFSetup/CompanyContext/`

## ❓ Troubleshooting

### Build Fails
```bash
# Clean build folder
cd "/Users/jamesmbualungu/Desktop/Coding/Investor Tool"
xcodebuild -project "Investor Tool.xcodeproj" clean

# Rebuild
xcodebuild -project "Investor Tool.xcodeproj" \
  -scheme "Investor Tool" \
  -sdk iphonesimulator \
  build
```

### View Doesn't Load
- Check Console for errors
- Verify `DCFFlowState` is in environment
- Verify ticker is passed correctly

### Heat Map Looks Wrong
- Check screen width calculation
- Verify `HeatMapModel` has correct column count
- Ensure all cells have valid scores (0.0 - 1.0)

## ✅ Verification Checklist

- [ ] Project builds without errors
- [ ] App launches in simulator
- [ ] Can navigate to Company Context screen
- [ ] Snapshot hero card displays correctly
- [ ] Heat map renders with 4 rows × 3 columns
- [ ] Driver cards show with sensitivity badges
- [ ] Competitor chips scroll horizontally
- [ ] Risk cards display with impact badges
- [ ] Framing card shows investment thesis
- [ ] Bottom CTA button works and navigates
- [ ] Dark mode looks good
- [ ] Different tickers show different data
- [ ] AAPL shows Consumer Tech archetype
- [ ] MSFT shows Enterprise SaaS archetype
- [ ] AMZN shows Commerce+Cloud archetype
- [ ] F shows Cyclical Manufacturing archetype
- [ ] Unknown ticker shows Generic archetype

## 🎉 You're Done!

The Company Context screen is now fully upgraded and ready to use. Enjoy the Robinhood-style UI!

When you're ready to integrate a backend:
1. Read `backend/company-context-api-contract.md`
2. Implement `SupabaseCompanyContextProvider`
3. Swap the provider in `CompanyContextView` initialization
4. No UI changes needed!

---

**Questions?** Check the implementation summary or the inline code comments.
