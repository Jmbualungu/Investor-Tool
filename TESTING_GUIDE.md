# Testing Guide - Blank Screen Fix

## Quick Start

### 1. Build the App
```bash
cd "/Users/jamesmbualungu/Desktop/Coding/Investor Tool"
xcodebuild -project "Investor Tool.xcodeproj" \
           -scheme "Investor Tool" \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
           clean build
```

Expected: ✅ BUILD SUCCEEDED

### 2. Open in Xcode
```bash
open "Investor Tool.xcodeproj"
```

### 3. Run on Simulator
- Select iPhone 17 Pro (or any iOS simulator)
- Press ⌘R to run

## Test Scenarios

### Scenario 1: First Launch (Onboarding)

**Setup:**
```bash
./scripts/reset_onboarding.sh
```

**Expected Behavior:**
1. ✅ App launches showing onboarding (not blank)
2. ✅ Three pages with page indicators at bottom
3. ✅ "Skip" button visible in top-right
4. ✅ Debug overlay in top-left shows:
   - `hasSeenOnboarding: false`
   - `path: 0`
   - `ticker: nil`
5. ✅ Can swipe through pages
6. ✅ "Continue →" button on pages 1-2
7. ✅ "Start forecasting →" button on page 3
8. ✅ Tapping "Start forecasting" shows ticker search

### Scenario 2: Returning User (Skip Onboarding)

**Setup:** Complete onboarding once

**Expected Behavior:**
1. ✅ App launches directly to DCFTickerSearchView
2. ✅ Debug overlay shows:
   - `hasSeenOnboarding: true`
   - `path: 0`
   - `ticker: nil`
3. ✅ Search field is visible and functional
4. ✅ Popular tickers show as chips

### Scenario 3: Full DCF Flow

**Steps:**
1. Launch app (should show ticker search if onboarding complete)
2. Type "AAPL" in search
3. Tap on Apple Inc.
4. Verify CompanyContextView shows
5. Tap "Continue"
6. Verify InvestmentLensView shows
7. Select horizon, style, objective
8. Tap "Continue"
9. Verify RevenueDriversView shows
10. Adjust sliders
11. Tap "Continue"
12. Verify OperatingAssumptionsView shows
13. Tap "Continue"
14. Verify ValuationAssumptionsView shows
15. Tap "Continue"
16. Verify ValuationResultsView shows
17. Tap sensitivity button
18. Verify SensitivityAnalysisView shows

**Expected Throughout:**
- ✅ No blank screens at any point
- ✅ Debug overlay updates:
  - `path` increases with each navigation
  - `ticker` shows "AAPL" after selection
- ✅ Back button works correctly
- ✅ Navigation is smooth
- ✅ All content is visible

### Scenario 4: Debug Overlay Verification

**Check these values at each step:**

| Screen | hasSeenOnboarding | path | ticker |
|--------|-------------------|------|--------|
| Onboarding Page 1 | false | 0 | nil |
| Onboarding Page 3 | false | 0 | nil |
| Ticker Search | true | 0 | nil |
| Company Context | true | 1 | AAPL |
| Investment Lens | true | 2 | AAPL |
| Revenue Drivers | true | 3 | AAPL |
| Operating | true | 4 | AAPL |
| Valuation | true | 5 | AAPL |
| Results | true | 6 | AAPL |
| Sensitivity | true | 7 | AAPL |

## Common Issues & Solutions

### Issue: Onboarding doesn't show
**Solution:**
```bash
./scripts/reset_onboarding.sh
```
Then relaunch the app.

### Issue: Blank screen appears
**Check:**
1. Is debug overlay visible?
   - NO → RootAppView isn't mounting (check Xcode console)
   - YES → Check overlay values for clues

2. What does debug overlay show?
   - `hasSeenOnboarding: false` → Onboarding should show
   - `hasSeenOnboarding: true` → Ticker search should show

### Issue: Navigation doesn't work
**Check:**
1. Does `path` increase in debug overlay when navigating?
   - NO → Navigation not working (check console for errors)
   - YES → View might not be receiving environment objects

### Issue: App crashes on launch
**Check Xcode console for:**
- Missing environment objects
- Force unwraps failing
- View init errors

## Removing Debug Overlay (After Testing)

Once verified working, remove the overlay:

**File:** `Investor Tool/App/RootAppView.swift`

**Remove this code:**
```swift
.overlay(alignment: .topLeading) {
    debugOverlay
}
```

And remove the `debugOverlay` computed property:
```swift
private var debugOverlay: some View {
    // Delete this entire computed property
}
```

## Performance Checks

### Memory
- Check Xcode memory graph for leaks
- FlowState should be retained only once

### Navigation
- Back button should pop correctly
- Path should reduce when going back

### State
- `hasSeenOnboarding` should persist across launches
- Ticker selection should persist during session

## Success Criteria

✅ **Primary:**
- [ ] No blank screens on any path
- [ ] Onboarding shows on first launch
- [ ] Main app shows on subsequent launches
- [ ] All navigation works

✅ **Secondary:**
- [ ] Debug overlay shows correct values
- [ ] Back navigation works
- [ ] State persists correctly
- [ ] Build has no warnings

## Next Steps After Testing

1. **Remove debug overlay** (see above)
2. **Archive old files** (optional):
   - `App/AppRouter.swift` (if no longer needed)
   - `App/RootView.swift` (if no longer needed)
3. **Update documentation** (if needed)
4. **Create PR or commit changes**

## Contact Points

If issues persist after following this guide:
1. Check `BLANK_SCREEN_FIX_SUMMARY.md` for technical details
2. Review build logs in Xcode
3. Check console logs for runtime errors
4. Verify all views exist in project
