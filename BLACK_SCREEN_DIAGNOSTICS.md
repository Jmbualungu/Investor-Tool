# 🔍 Black Screen Diagnostics - Setup Complete

## Status: ✅ DIAGNOSTICS MODE ACTIVE

The app has been configured to show a minimal diagnostics view to isolate the black screen issue.

---

## 🎯 What Was Done

### 1. Created DiagnosticsRootView.swift
A minimal SwiftUI view with **zero dependencies**:
- Bright yellow background (opacity 0.25)
- Large "DIAGNOSTICS ROOT" text
- Current date/time display
- "App is running" indicator

### 2. Updated ForecastAIApp.swift
Temporarily using `DiagnosticsRootView()` instead of `AppRoot()` to test if SwiftUI rendering works.

### 3. Created Test Scripts
- `scripts/test_diagnostics.sh` - Build and verify diagnostics mode
- `scripts/restore_approot.sh` - Switch back to normal AppRoot
- `scripts/enable_diagnostics.sh` - Switch to diagnostics mode

### 4. Build Status: ✅ SUCCESS
Project builds successfully with diagnostics view.

---

## 🚀 Quick Start

### Option 1: Run Test Script (Recommended)

```bash
cd "/Users/jamesmbualungu/Desktop/Coding/Investor Tool"
./scripts/test_diagnostics.sh
```

This will:
- ✅ Verify diagnostics mode is active
- ✅ Build the project
- ✅ Show instructions

### Option 2: Manual Test

```bash
# Open Xcode
open "Investor Tool.xcodeproj"

# Press Cmd+R to build and run
# Select iPhone 15 Pro simulator
```

---

## 📊 What You Should See

### ✅ SUCCESS: Yellow Diagnostics Screen

```
┌─────────────────────────────────────┐
│                                     │
│    🟨 Light Yellow Background       │
│                                     │
│        DIAGNOSTICS ROOT             │
│                                     │
│    If you can see this, the app     │
│    is launching and rendering       │
│    SwiftUI.                         │
│                                     │
│    2026-01-19 10:45:00 +0000        │
│    ─────────────────────            │
│    App is running ✅                │
│                                     │
└─────────────────────────────────────┘
```

**This means:**
- ✅ SwiftUI is working correctly
- ✅ The app is launching
- ✅ Basic rendering works
- ❌ The issue is specifically with `AppRoot` or its dependencies

**Next steps:**
```bash
# Restore normal app to debug AppRoot
./scripts/restore_approot.sh
```

Then check `DIAGNOSTICS_GUIDE.md` for AppRoot recovery steps.

---

### ❌ FAILURE: Still Black Screen

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│         ⬛ BLACK SCREEN              │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

**This means:**
- ❌ Deeper system issue
- Problem is NOT just AppRoot
- SwiftUI might not be rendering at all

**Immediate actions:**

1. **Check Console** (Cmd+Shift+Y in Xcode)
   ```
   Look for:
   - "fatal error"
   - "Thread 1: ..."
   - Crash logs
   - SwiftUI warnings
   ```

2. **Clean Build**
   ```bash
   # In Xcode:
   Product → Clean Build Folder (Cmd+Shift+K)
   
   # Then rebuild and run
   ```

3. **Reset Simulator**
   ```
   Simulator menu:
   Device → Erase All Content and Settings
   ```

4. **Clear Derived Data**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Investor_Tool-*
   ```

5. **Try Different Simulator**
   - Switch from iPhone 17 to iPhone 15 Pro
   - Or vice versa

6. **Check Build Logs**
   ```bash
   # Look for any warnings during build
   # Especially about missing files or modules
   ```

---

## 🔄 Switching Modes

### Currently: DIAGNOSTICS MODE ✅

The app shows `DiagnosticsRootView`.

### To Restore Normal App:

```bash
./scripts/restore_approot.sh
```

This switches back to `AppRoot()`.

### To Return to Diagnostics:

```bash
./scripts/enable_diagnostics.sh
```

---

## 🐛 Debugging Flow

```
1. Run Diagnostics
   ./scripts/test_diagnostics.sh
       ↓
   ┌─────────────────────┐
   │ See Yellow Screen?  │
   └─────────────────────┘
       ↓           ↓
      YES         NO
       ↓           ↓
       ↓       Check Console
       ↓       Clean Build
       ↓       Reset Simulator
       ↓
2. Issue is in AppRoot
   ./scripts/restore_approot.sh
       ↓
   Test AppRoot
       ↓
   ┌─────────────────────┐
   │ See Black Screen?   │
   └─────────────────────┘
       ↓           ↓
      YES         NO
       ↓           ↓
       ↓       ✅ Fixed!
       ↓
3. Debug AppRoot Components
   - Test without FlowState
   - Test without Navigation
   - Test without onboarding check
   - Test minimal views
       ↓
   Isolate the issue
       ↓
   Fix specific component
```

---

## 📁 Files Created

| File | Purpose |
|------|---------|
| `App/DiagnosticsRootView.swift` | Minimal yellow test view |
| `DIAGNOSTICS_GUIDE.md` | Detailed troubleshooting guide |
| `BLACK_SCREEN_DIAGNOSTICS.md` | This file |
| `scripts/test_diagnostics.sh` | Automated test script |
| `scripts/restore_approot.sh` | Switch to normal mode |
| `scripts/enable_diagnostics.sh` | Switch to diagnostics mode |

---

## 📋 Current Configuration

```swift
// ForecastAIApp.swift
WindowGroup {
    DiagnosticsRootView()  // ← Currently active
    // AppRoot()           // ← Commented out
}
```

To verify:
```bash
cat "Investor Tool/App/ForecastAIApp.swift"
```

---

## 🎯 Next Steps

### Right Now:

1. **Run the diagnostics test:**
   ```bash
   ./scripts/test_diagnostics.sh
   ```

2. **Open Xcode and run (Cmd+R)**

3. **Observe what you see:**
   - Yellow screen = SwiftUI works, issue is AppRoot
   - Black screen = Deeper issue, check console

4. **Report back with:**
   - What you saw on screen
   - Any console errors
   - Whether build succeeded

### If Yellow Screen:

1. ✅ Good news - SwiftUI works
2. Switch back to AppRoot:
   ```bash
   ./scripts/restore_approot.sh
   ```
3. Test if AppRoot shows black screen
4. If yes, follow AppRoot recovery steps in `DIAGNOSTICS_GUIDE.md`

### If Black Screen:

1. ❌ Deeper issue
2. Check console output
3. Try all cleanup steps (clean, reset simulator, etc.)
4. Check if simulator itself works with other apps
5. Consider Xcode reinstall if nothing works

---

## 📚 Documentation

- **DIAGNOSTICS_GUIDE.md** - Comprehensive troubleshooting
- **BLACK_SCREEN_DIAGNOSTICS.md** - This quick start (you are here)
- **SIMULATOR_BUILD_HARNESS.md** - Original build harness docs
- **BUILD_HARNESS_QUICKREF.md** - Quick reference

---

## ✅ Verification

Run this to confirm diagnostics mode is active:

```bash
grep -q "DiagnosticsRootView()" \
  "Investor Tool/App/ForecastAIApp.swift" && \
  echo "✅ Diagnostics mode active" || \
  echo "❌ Diagnostics mode NOT active"
```

Expected output: `✅ Diagnostics mode active`

---

## 🆘 Still Stuck?

If you've tried everything and still see black screen:

1. **Check Xcode version**: Make sure it's up to date
2. **Check macOS version**: Compatibility issues?
3. **Try a simple "Hello World" app**: Does that work?
4. **Check simulator logs**: Console.app → search for "Simulator"
5. **Try real device**: If available, test on actual iPhone

---

**Diagnostics Version**: 1.0  
**Created**: January 19, 2026  
**Status**: Ready to test  
**Current Mode**: Diagnostics (DiagnosticsRootView)
