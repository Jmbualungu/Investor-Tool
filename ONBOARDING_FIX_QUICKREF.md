# Onboarding Fix - Quick Reference

## What Was Fixed
Blank screen issue caused by improper onboarding gating and navigation setup.

## Files Changed

### ✅ NEW
- `App/RootAppView.swift` - Single unified entry point
- `scripts/reset_onboarding.sh` - Reset onboarding for testing

### ✅ MODIFIED  
- `App/ForecastAIApp.swift` - Use RootAppView instead of AppRouter
- `Features/Onboarding/FirstLaunchOnboardingView.swift` - Added background & skip button

## Key Architecture Changes

### Before
```swift
@main
struct ForecastAIApp: App {
    var body: some Scene {
        WindowGroup {
            AppRouter()  // ❌ Complex ZStack overlay pattern
        }
    }
}
```

### After
```swift
@main
struct ForecastAIApp: App {
    var body: some Scene {
        WindowGroup {
            RootAppView()  // ✅ Simple, unified entry point
        }
    }
}
```

## RootAppView Structure

```swift
struct RootAppView: View {
    @StateObject private var flowState = DCFFlowState()           // ✅ Owned here
    @State private var path: [AppRoute] = []                      // ✅ Owned here
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if hasSeenOnboarding {
                    DCFTickerSearchView(...)     // Main app
                } else {
                    FirstLaunchOnboardingView(...)  // Onboarding
                }
            }
            .environmentObject(flowState)  // ✅ Injected to BOTH paths
            .navigationDestination(for: AppRoute.self) { route in
                // All routing logic
            }
        }
        .overlay(alignment: .topLeading) {
            debugOverlay  // 🐛 For debugging (can be removed)
        }
    }
}
```

## Testing Commands

### Build
```bash
cd "/Users/jamesmbualungu/Desktop/Coding/Investor Tool"
xcodebuild -project "Investor Tool.xcodeproj" \
           -scheme "Investor Tool" \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
           clean build
```

### Reset Onboarding
```bash
./scripts/reset_onboarding.sh
```

### Open in Xcode
```bash
open "Investor Tool.xcodeproj"
```

## Debug Overlay Values

| Location | hasSeenOnboarding | path | ticker |
|----------|-------------------|------|--------|
| Onboarding | `false` | `0` | `nil` |
| Ticker Search | `true` | `0` | `nil` |
| Company Context | `true` | `1` | Selected symbol |
| Investment Lens | `true` | `2` | Selected symbol |
| Revenue Drivers | `true` | `3` | Selected symbol |
| Operating | `true` | `4` | Selected symbol |
| Valuation | `true` | `5` | Selected symbol |
| Results | `true` | `6` | Selected symbol |
| Sensitivity | `true` | `7` | Selected symbol |

## Expected Behavior

### ✅ First Launch
1. App shows onboarding (3 pages)
2. Skip button in top-right
3. Page indicators at bottom
4. "Start forecasting →" button on page 3
5. Tapping advances to ticker search

### ✅ Subsequent Launches
1. App opens directly to ticker search
2. No onboarding shown
3. Navigation works through full DCF flow

### ✅ Navigation Flow
Ticker Search → Company Context → Investment Lens → Revenue Drivers → Operating → Valuation → Results → Sensitivity

## Troubleshooting

| Problem | Check | Solution |
|---------|-------|----------|
| Blank screen | Debug overlay visible? | If NO: Check console. If YES: Check overlay values |
| Onboarding not showing | hasSeenOnboarding value? | Run `./scripts/reset_onboarding.sh` |
| Navigation broken | path increasing? | Check environment injection |
| Build fails | Xcode errors? | Check all files exist |

## Remove Debug Overlay

After testing, remove from `RootAppView.swift`:

```swift
// DELETE THIS:
.overlay(alignment: .topLeading) {
    debugOverlay
}

// AND DELETE THIS:
private var debugOverlay: some View {
    // ...
}
```

## Success Criteria

- [x] Build succeeds ✅
- [x] No linter errors ✅
- [ ] Onboarding shows on first launch (test on simulator)
- [ ] Main app shows on subsequent launches
- [ ] Full navigation flow works
- [ ] No blank screens anywhere

## Documentation

- **Technical Details:** See `BLANK_SCREEN_FIX_SUMMARY.md`
- **Testing Guide:** See `TESTING_GUIDE.md`
- **This File:** Quick reference for common tasks

## Key Takeaways

1. **Single Entry Point:** RootAppView owns all root state
2. **NavigationStack Wraps Both:** Onboarding and app in same stack
3. **Environment Injection Order:** Must be outside if/else
4. **Debug Overlay:** Helps verify state during development
5. **Callback Pattern:** OnboardingView calls back to flip flag
