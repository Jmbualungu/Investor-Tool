# Build Harness Quick Reference

## 🚀 One-Command Test

```bash
cd "/Users/jamesmbualungu/Desktop/Coding/Investor Tool" && \
xcodebuild -project "Investor Tool.xcodeproj" \
           -scheme "Investor Tool" \
           -sdk iphonesimulator \
           build
```

---

## 📍 Key Files

| File | Purpose |
|------|---------|
| `App/AppRoot.swift` | Single entry point, creates FlowState & navigation |
| `App/DebugHUD.swift` | Debug overlay (DEBUG builds only) |
| `App/ForecastAIApp.swift` | @main entry, calls `AppRoot()` |

---

## 🔧 Quick Tasks

### Verify Simulator is Running Latest Code
1. Edit `AppRoot.swift` → change `buildStamp` to `"BuildStamp-002"`
2. Build and run
3. Check Debug HUD in top-left corner shows new stamp

### Reset App Without Reinstalling
1. Run app in simulator
2. Tap **"Reset App State"** in Debug HUD (top-left)
3. App returns to onboarding with clean state

### Hide Debug HUD (for screenshots)
Debug HUD only shows in DEBUG builds. For Release:
```swift
#if DEBUG
  // HUD code - automatically hidden in Release
#endif
```

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Blank screen | Check Debug HUD visibility, tap "Reset App State" |
| Changes not showing | Update build stamp, verify in Debug HUD |
| Navigation broken | Check path binding in AppRoot |
| Missing FlowState | AppRoot creates it, check `.environmentObject()` |

---

## 📊 Architecture at a Glance

```
ForecastAIApp (@main)
    ↓
AppRoot (single root)
    ├─ @StateObject flowState (created once)
    ├─ @State path (navigation)
    ├─ NavigationStack
    │   ├─ Onboarding (if not seen)
    │   └─ DCFTickerSearchView (if seen)
    └─ DebugHUD overlay
```

---

## ✅ What It Fixes

✅ No more blank screens  
✅ FlowState always injected  
✅ Changes reliably show in simulator  
✅ One-tap reset (no reinstall needed)  
✅ Stable navigation (path created once)  
✅ Visible build verification

---

## 🎯 Build Status: ✅ SUCCESS

Last verified: 2026-01-19
- iOS Simulator: ✅
- All files compiled: ✅
- No errors/warnings: ✅
