# 🚨 START HERE - Black Screen Fix

## You're seeing a BLACK SCREEN. Let's fix it.

---

## ⚡ QUICK FIX - Do This Now

### Step 1: Run Test (30 seconds)

```bash
cd "/Users/jamesmbualungu/Desktop/Coding/Investor Tool"
./scripts/test_diagnostics.sh
```

### Step 2: Open Xcode and Run

```bash
open "Investor Tool.xcodeproj"
# Press Cmd+R to run
```

### Step 3: What Do You See?

---

## 🟨 If You See YELLOW Screen

```
┌─────────────────────┐
│  🟨 DIAGNOSTICS ROOT │
│  (yellow background) │
└─────────────────────┘
```

### ✅ GOOD NEWS!

**SwiftUI is working.** The issue is with AppRoot.

### Next Step:

```bash
# Switch back to normal app
./scripts/restore_approot.sh

# Then run again in Xcode
# If you see black screen, check DIAGNOSTICS_GUIDE.md
```

---

## ⬛ If You Still See BLACK Screen

```
┌─────────────────────┐
│  ⬛ BLACK SCREEN     │
│  (nothing visible)   │
└─────────────────────┘
```

### ❌ DEEPER ISSUE

Do these in order:

### 1. Check Console (30 seconds)
In Xcode, press **Cmd+Shift+Y** to open console.

Look for:
- Red error messages
- "fatal error"
- "Thread 1:"
- Crash logs

Copy any errors you see.

### 2. Clean Build (1 minute)
In Xcode:
- **Product → Clean Build Folder** (Cmd+Shift+K)
- Wait for it to finish
- **Product → Build** (Cmd+B)
- **Product → Run** (Cmd+R)

Still black?

### 3. Reset Simulator (2 minutes)
In Simulator:
- **Device → Erase All Content and Settings**
- Confirm
- Wait for reset
- Run app again (Cmd+R in Xcode)

Still black?

### 4. Clear Derived Data (2 minutes)
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/Investor_Tool-*
```

Then in Xcode:
- Build and run again (Cmd+R)

Still black?

### 5. Try Different Simulator
In Xcode:
- Click simulator dropdown at top
- Select **iPhone 15 Pro** (or different model than current)
- Run again (Cmd+R)

---

## 📊 Decision Tree

```
Run ./scripts/test_diagnostics.sh
        ↓
Open Xcode and run (Cmd+R)
        ↓
    ┌───────┐
    │ Screen│
    └───────┘
        ↓
    ┌───┴───┐
   🟨      ⬛
YELLOW   BLACK
    ↓       ↓
    ✅      ❌
 SwiftUI  Deeper
 works    issue
    ↓       ↓
Restore  Clean
AppRoot  Build
```

---

## 🎯 Most Likely Causes

### Yellow Screen (SwiftUI works):
1. AppRoot has an error
2. FlowState initialization fails
3. Navigation setup is wrong
4. Child view crashes
5. EnvironmentObject missing

### Black Screen (Even diagnostics fail):
1. Simulator issue
2. Xcode cache corrupted
3. Build configuration problem
4. Code signing issue
5. iOS SDK problem

---

## 📞 Quick Commands

```bash
# Test diagnostics
./scripts/test_diagnostics.sh

# Restore normal app
./scripts/restore_approot.sh

# Switch back to diagnostics
./scripts/enable_diagnostics.sh

# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/Investor_Tool-*

# Open Xcode
open "Investor Tool.xcodeproj"
```

---

## 🆘 Emergency: Nothing Works

If you've tried EVERYTHING and still see black:

### Last Resort Steps:

1. **Restart Mac**
   - Sometimes fixes Xcode/Simulator issues

2. **Reinstall Xcode Command Line Tools**
   ```bash
   xcode-select --install
   ```

3. **Create New Test Project**
   - File → New → Project → iOS App
   - Single View App
   - Run it
   - Does that work? If no, Xcode is broken.

4. **Check macOS Console.app**
   - Open Console.app
   - Filter for "Simulator" or "Investor Tool"
   - Look for crash logs

---

## ✅ Success Criteria

You've fixed it when you see:

- ✅ Yellow diagnostics screen (first test)
- ✅ App interface visible (after restoring AppRoot)
- ✅ Debug HUD in top-left (if using AppRoot with harness)
- ✅ Can navigate through app

---

## 📚 More Help

- **DIAGNOSTICS_GUIDE.md** - Detailed troubleshooting
- **BLACK_SCREEN_DIAGNOSTICS.md** - Complete diagnostic info
- **SIMULATOR_BUILD_HARNESS.md** - Build harness docs

---

## ⏱️ Time Estimates

- Running test: **30 seconds**
- Clean build: **1 minute**
- Reset simulator: **2 minutes**
- Clear derived data: **2 minutes**
- All troubleshooting: **10-15 minutes max**

---

## 🎬 Action Plan

1. ✅ Read this page (you just did)
2. ⏳ Run `./scripts/test_diagnostics.sh`
3. ⏳ Open Xcode and run (Cmd+R)
4. ⏳ Check what you see (yellow or black)
5. ⏳ Follow instructions based on result

**Start now. This will take less than 5 minutes.**

---

**Last Updated**: January 19, 2026  
**Status**: Ready to test  
**Mode**: Diagnostics active
