# Blank Screen Fix Summary

## Issue
The app was showing a blank screen due to onboarding gating issues. The navigation stack, flow state, and environment injection were not properly configured.

## Solution
Created a single, unified root view that properly manages:
- Onboarding state
- Navigation stack and routing
- FlowState injection
- Environment configuration

## Changes Made

### 1. Created `RootAppView.swift` (NEW FILE)
**Location:** `Investor Tool/App/RootAppView.swift`

**Purpose:** Single entry point for the entire app with proper state management.

**Key Features:**
- Owns `DCFFlowState` as `@StateObject` - shared across entire app
- Owns navigation path: `@State private var path: [AppRoute] = []`
- Owns onboarding gate: `@AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false`
- Uses `NavigationStack(path: $path)` wrapping both onboarding and main app
- Injects `environmentObject(flowState)` OUTSIDE the if/else so both paths get it
- Provides complete routing for all DCF Setup Flow screens
- Includes debug overlay showing:
  - `hasSeenOnboarding` value
  - Navigation path count
  - Selected ticker symbol

**Layout Structure:**
```swift
NavigationStack(path: $path) {
    Group {
        if hasSeenOnboarding {
            DCFTickerSearchView(...)  // Main app entry
        } else {
            FirstLaunchOnboardingView(...)  // Onboarding
        }
    }
    .environmentObject(flowState)  // ✅ Applied to BOTH paths
    .navigationDestination(for: AppRoute.self) { route in
        // All route handling
    }
}
```

### 2. Updated `ForecastAIApp.swift`
**Changed:**
```swift
// Before:
WindowGroup {
    AppRouter()
}

// After:
WindowGroup {
    RootAppView()
}
```

**Impact:** App now uses the new unified root view instead of the old AppRouter.

### 3. Updated `FirstLaunchOnboardingView.swift`
**Changes:**
- Added explicit non-transparent background:
  ```swift
  Color(.systemBackground).ignoresSafeArea()
  ```
- Added "Skip" button in top-right for debugging:
  ```swift
  Button("Skip") {
      completeOnboarding()
  }
  ```
- Changed TabView style to show page indicators:
  ```swift
  .tabViewStyle(.page(indexDisplayMode: .always))
  ```

**Impact:** Onboarding is now always visibly rendered with proper background.

### 4. Created Helper Script
**File:** `scripts/reset_onboarding.sh`

**Purpose:** Reset onboarding state for testing.

**Usage:**
```bash
./scripts/reset_onboarding.sh
```

This deletes the `hasSeenOnboarding` UserDefaults key and kills the app, forcing onboarding to show on next launch.

## Architecture Benefits

### Before (AppRouter)
- ZStack overlay for onboarding
- Separate state management
- Complex conditional logic
- Environment injection inconsistencies
- Navigation path not accessible everywhere

### After (RootAppView)
- Single NavigationStack for entire app
- Unified state management (FlowState owned at root)
- Simple if/else for onboarding gate
- Consistent environment injection
- Navigation path accessible via environment
- Debug overlay for troubleshooting

## Key Technical Points

### 1. Environment Injection Order Matters
```swift
Group {
    if hasSeenOnboarding {
        // Main app
    } else {
        // Onboarding
    }
}
.environmentObject(flowState)  // ✅ Must be OUTSIDE Group
```

If `.environmentObject()` is inside the if/else, only one path gets it.

### 2. NavigationStack Wraps Everything
Both onboarding and main app are inside the same `NavigationStack`, ensuring:
- Navigation always works
- Routes can be pushed from anywhere
- Path is maintained properly

### 3. OnboardingView Callback Pattern
```swift
FirstLaunchOnboardingView(
    onComplete: {
        hasSeenOnboarding = true
    }
)
```

Explicit callback ensures the parent (RootAppView) updates the gating state.

### 4. Debug Overlay
The debug overlay helps verify:
- Is onboarding state correct?
- Is navigation path populated?
- Is ticker selection working?

Can be removed by deleting the `.overlay` modifier in RootAppView.

## Testing the Fix

### 1. Fresh Install (See Onboarding)
```bash
# Reset onboarding state
./scripts/reset_onboarding.sh

# Build and run
xcodebuild -project "Investor Tool.xcodeproj" \
           -scheme "Investor Tool" \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
           clean build
```

**Expected:**
- ✅ Onboarding shows (3 pages with indicators)
- ✅ "Skip" button visible in top-right
- ✅ Debug overlay shows `hasSeenOnboarding: false`
- ✅ Tapping "Start forecasting" advances to ticker search
- ✅ Debug overlay updates to `hasSeenOnboarding: true`

### 2. Returning User (Skip Onboarding)
After completing onboarding once:
- ✅ App opens directly to DCFTickerSearchView
- ✅ Debug overlay shows `hasSeenOnboarding: true`
- ✅ Navigation works through entire DCF flow

### 3. Full Flow Test
1. Complete onboarding
2. Search for a ticker (e.g., "AAPL")
3. Select ticker → CompanyContextView
4. Tap Continue → InvestmentLensView
5. Select horizon/style → RevenueDriversView
6. Continue through Operating → Valuation → Results → Sensitivity

**Expected:**
- ✅ No blank screens at any point
- ✅ Navigation path count increases in debug overlay
- ✅ Selected ticker shows in debug overlay
- ✅ Back button navigation works correctly

## File Changes Summary

| File | Status | Purpose |
|------|--------|---------|
| `App/RootAppView.swift` | NEW | Single unified entry point |
| `App/ForecastAIApp.swift` | MODIFIED | Use RootAppView instead of AppRouter |
| `Features/Onboarding/FirstLaunchOnboardingView.swift` | MODIFIED | Add background, skip button, visible indicators |
| `scripts/reset_onboarding.sh` | NEW | Helper script for testing |

## Build Status
✅ **Build Succeeded** - No compilation errors
✅ **No Linter Errors** - Code passes all checks

## Next Steps

1. **Test on Simulator:** Launch the app and verify onboarding shows
2. **Test Navigation:** Complete full DCF flow to ensure no blank screens
3. **Remove Debug Overlay:** Once verified, remove the `.overlay` modifier from RootAppView
4. **Clean Up Old Code:** Consider removing or archiving `AppRouter.swift` if no longer needed

## Troubleshooting

### If onboarding doesn't show:
```bash
# Reset the flag
./scripts/reset_onboarding.sh
```

### If navigation doesn't work:
- Check debug overlay to verify path count is increasing
- Verify environment injection (flowState should be non-nil)

### If blank screen still occurs:
- Check debug overlay is visible (if not, RootAppView isn't mounting)
- Verify `hasSeenOnboarding` value in debug overlay
- Check console logs for any runtime errors

## Technical Notes

### Why This Approach?
1. **Single Source of Truth:** One place owns all navigation and state
2. **Predictable Flow:** Linear onboarding → main app transition
3. **Testable:** Can easily reset and test both paths
4. **Maintainable:** Clear structure, easy to debug

### Alternative Considered
Using a ZStack overlay (old approach) was rejected because:
- Complex state coordination
- Environment injection issues
- Harder to debug
- Non-standard navigation patterns

### Design Principles Followed
- ✅ Unidirectional data flow
- ✅ Minimal state at root
- ✅ Explicit over implicit
- ✅ SwiftUI best practices (state-driven UI)
