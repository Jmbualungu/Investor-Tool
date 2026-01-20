# Robinhood UI Fix - Build Verification Guide

## Summary of Changes

### 1. Fixed Safe Mode Default (CRITICAL)
**File: `App/GlobalAppConfig.swift`**
- Changed Safe Mode default from `true` → `false`
- Safe Mode now ONLY activates when manually toggled in Settings
- Old behavior: Safe Mode was ON by default, showing "Safe Mode Active" screens
- New behavior: Safe Mode is OFF by default, showing the new Robinhood-like UI

### 2. Added Build Stamp Overlay
**File: `App/ForecastAIApp.swift`**
- Added visible build stamp: **"RH-UI-2026-01-20"**
- Shows in top-left corner on DEBUG builds
- Allows you to verify the physical device is running the latest build
- If you don't see this stamp, the device is running an old build

### 3. Added Safe Mode Toggle in Settings
**File: `Features/Shell/SettingsView.swift`**
- Added "Safe Mode" toggle in Developer Tools section (DEBUG only)
- Added "Reset All Flags" button to reset onboarding and safe mode
- Safe Mode can now be controlled manually instead of being automatic

### 4. Confirmed App Entry Point
**File: `App/ForecastAIApp.swift`** (already correct)
- ✅ Single `@main` entry point
- ✅ Shows `AppShellView` (new Robinhood-like tabs) as default root
- ✅ Onboarding gate works correctly
- ✅ No fallback to old UI views

---

## How to Verify the Build on Physical Device

### Step 1: Clean Build
```bash
# In Xcode:
1. Product → Clean Build Folder (⌘⇧K)
2. Delete app from physical device
3. Build and run to physical device (⌘R)
```

### Step 2: Check for Build Stamp
**Look for the build stamp in the top-left corner:**
- Should see: **"RH-UI-2026-01-20"** in a frosted glass container
- If you DON'T see it: Device is running an old build → repeat Step 1

### Step 3: Verify New UI
You should see:
- ✅ Robinhood-like tab bar at bottom (Watchlist, Forecast, Library, Settings)
- ✅ Modern glass-morphism design system
- ✅ Forecast tab shows "Start a Forecast" hero section
- ✅ NO "Safe Mode Active" banner
- ✅ NO "Using sample ticker: AAPL" text

### Step 4: Test Safe Mode Toggle
1. Go to Settings tab
2. Scroll to "Developer Tools" section (DEBUG only)
3. Toggle "Safe Mode" ON
4. Navigate to Forecast tab
5. Search should still work normally (Safe Mode doesn't affect AppShellView UI)

---

## Troubleshooting

### Issue: Physical device still shows "Safe Mode Active" screen

**Cause:** Device has cached UserDefaults from old builds where Safe Mode defaulted to `true`.

**Fix Option 1 - Delete and Reinstall (RECOMMENDED):**
```bash
1. Delete app from physical device
2. In Xcode: Product → Clean Build Folder (⌘⇧K)
3. Build and run to device (⌘R)
```

**Fix Option 2 - Use Reset Button:**
```bash
1. If you can access Settings in the old UI
2. Find "Reset All Flags" button in Developer Tools
3. Tap it → app will reset to onboarding
```

### Issue: Build stamp doesn't appear

**Cause:** Running a Release build instead of Debug build.

**Fix:**
```bash
1. In Xcode, check scheme is set to "Debug" not "Release"
2. Edit Scheme → Run → Build Configuration → Debug
```

### Issue: App crashes on launch

**Check for:**
1. Missing `environmentObject(config)` - should be fixed now
2. SwiftData model context issues - check Console logs
3. Missing imports or dependencies

---

## Architecture Notes

### Current App Entry Flow
```
ForecastAIApp (@main)
  ↓
Check hasSeenOnboarding?
  ├─ NO  → OnboardingFlowView
  └─ YES → AppShellView
              ↓
            TabView (4 tabs)
              ├─ Watchlist (WatchlistView)
              ├─ Forecast (ForecastHomeView) ← Main DCF entry
              ├─ Library (LibraryView)
              └─ Settings (SettingsView)
```

### Legacy Views (NOT USED)
These views are **not referenced** in the new UI flow:
- ❌ `MainFlowView.swift` - Old flow with Safe Mode screens
- ❌ `SafeTickerSearchView` - Old "Safe Mode Active" screen
- ❌ `RootView.swift` - Old diagnostic root
- ❌ `DiagnosticsRootView.swift` - Old diagnostic UI
- ❌ `ContentView.swift` - Template file

These can be deleted in a future cleanup, but are harmless for now.

---

## Safe Mode Behavior (New)

### When Safe Mode is OFF (Default):
- Uses real TickerRepository data
- Shows live market data (when API is implemented)
- Normal DCF flow

### When Safe Mode is ON (Manual Toggle):
- Currently doesn't affect AppShellView UI
- Can be used for testing without API calls
- Can be extended to affect data sources in the future

**Important:** Safe Mode no longer changes the UI root. It only affects data sources.

---

## Next Steps

1. **Test on simulator first** to verify the build stamp appears
2. **Clean build to physical device** and check for build stamp
3. **If old UI persists:** Delete app, clean build, reinstall
4. **Verify all 4 tabs work** in the new UI
5. **Test DCF flow** from Forecast tab
6. **Test Safe Mode toggle** in Settings

---

## Build Stamp Updates

To verify future builds, update the build stamp in `ForecastAIApp.swift`:

```swift
private let buildStamp = "RH-UI-2026-01-20"  // ← Change this for new builds
```

Example naming conventions:
- `"RH-UI-2026-01-20"` - Major UI update
- `"DCF-FIX-2026-01-21"` - DCF logic fix
- `"HOTFIX-001"` - Emergency fix

---

## Questions?

- Build stamp not showing? → Check DEBUG build configuration
- Old UI still showing? → Delete app and reinstall
- App crashes? → Check Console logs for missing environmentObjects
