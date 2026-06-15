# Supabase Setup Checklist

Complete guide to set up Supabase Swift integration in this iOS project.

---

## ✅ Pre-Setup Verification

### 1. Check Current Status

**Secrets Configuration:** ✅ Fixed
- `Config/Secrets.xcconfig` now has correct format with `SUPABASE_URL =` prefix

**File Structure:** ✅ Ready
- `Core/Supabase/SupabaseClientProvider.swift` - Main client provider
- `Core/Supabase/SupabaseCompileCheck.swift` - Compile verification (DEBUG only)

**What's Missing:** ⚠️ SPM Package
- Supabase Swift package is **NOT yet added** to Xcode project
- This must be done manually (see Step 2 below)

---

## 🔧 Setup Steps

### Step 1: Verify Secrets Configuration ✅ (Already Done)

Your `Config/Secrets.xcconfig` should look like:
```xcconfig
SUPABASE_URL = https:/$()/udttgzeuzmuzkcqogegy.supabase.co
SUPABASE_PUBLISHABLE_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Status:** ✅ Already configured correctly

---

### Step 2: Add Supabase Swift Package (MANUAL - REQUIRED)

⚠️ **This MUST be done in Xcode - cannot be automated via command line**

**Follow these exact steps:**

1. **Open project in Xcode:**
   ```bash
   open "Investor Tool.xcodeproj"
   ```

2. **Add Package:**
   - Menu: **File** → **Add Package Dependencies...**
   - Paste URL: `https://github.com/supabase-community/supabase-swift`
   - Dependency Rule: **Up to Next Major Version** (2.0.0 < 3.0.0)
   - Click **Add Package**

3. **Select Target:**
   - Check ✅ **Investor Tool**
   - Select products: **Supabase**, Auth, PostgREST, Storage, Functions
   - Click **Add Package**

4. **Wait for Resolution:**
   - Xcode will download packages (1-2 minutes)
   - Status shows in bottom status bar

**Detailed instructions:** See `MANUAL_XCODE_STEP.md`

---

### Step 3: Verify Package is Linked

After adding package in Xcode:

**A. Check Project Navigator:**
1. Open Xcode project
2. Expand "Investor Tool" in left sidebar
3. Look for **"Package Dependencies"** section
4. Verify **supabase-swift** is listed

**B. Check Target Settings:**
1. Select target: **Investor Tool**
2. Tab: **General**
3. Section: **Frameworks, Libraries, and Embedded Content**
4. Verify Supabase frameworks appear:
   - Supabase
   - Auth
   - PostgREST
   - Storage
   - Functions
   - (plus dependencies like Helpers, HTTPTypes, etc.)

**C. Check Build Phases:**
1. Select target: **Investor Tool**
2. Tab: **Build Phases**
3. Expand: **Link Binary With Libraries**
4. Verify Supabase frameworks are listed

---

### Step 4: Clean Build

**Always do this after adding SPM packages:**

```bash
# In Xcode:
# 1. Product → Clean Build Folder (Shift+Cmd+K)
# 2. Product → Build (Cmd+B)
```

**Or via command line:**
```bash
cd "/Users/jamesmbualungu/Desktop/Coding/Investor Tool"
xcodebuild clean -project "Investor Tool.xcodeproj" -scheme "Investor Tool"
xcodebuild build -project "Investor Tool.xcodeproj" -scheme "Investor Tool"
```

---

### Step 5: Verify Import Compiles

**Open any file that imports Supabase and verify no errors:**

Files that import Supabase:
- `Core/Supabase/SupabaseClientProvider.swift`
- `Core/Supabase/SupabaseCompileCheck.swift`
- `Features/Auth/AuthViewModel.swift`
- `Features/Debug/BackendStatusView.swift`

**Check for:**
- ✅ No red error: "No such module 'Supabase'"
- ✅ SupabaseClient type recognized
- ✅ Autocomplete works for Supabase types

**Run compile check (optional):**
```swift
// In any DEBUG file or view
#if DEBUG
SupabaseCompileCheck.verify()
SupabaseCompileCheck.checkTypes()
#endif
```

---

## 🧪 Test Build

### Option 1: Build in Xcode (Recommended)
```
1. Cmd+B (Build)
2. Check for errors in Issue Navigator
3. If successful, proceed to run (Cmd+R)
```

### Option 2: Build via Command Line
```bash
cd "/Users/jamesmbualungu/Desktop/Coding/Investor Tool"

# Clean
xcodebuild clean -project "Investor Tool.xcodeproj" -scheme "Investor Tool"

# Build
xcodebuild build -project "Investor Tool.xcodeproj" -scheme "Investor Tool" -configuration Debug

# If successful, you should see:
# ** BUILD SUCCEEDED **
```

---

## ✅ Verification Checklist

Complete this checklist to confirm setup is correct:

### Package Installation:
- [ ] Opened Xcode project
- [ ] File → Add Package Dependencies
- [ ] Added: `https://github.com/supabase-community/supabase-swift`
- [ ] Selected target: "Investor Tool"
- [ ] Package appears in Project Navigator under "Package Dependencies"
- [ ] Frameworks appear in target "Frameworks, Libraries, and Embedded Content"

### Build Configuration:
- [ ] `Config/Secrets.xcconfig` has correct format (with `SUPABASE_URL =`)
- [ ] `SUPABASE_URL` contains real Supabase project URL
- [ ] `SUPABASE_PUBLISHABLE_KEY` contains real anon key
- [ ] Info.plist includes SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY entries

### Code:
- [ ] `import Supabase` statements have no errors
- [ ] SupabaseClient type is recognized
- [ ] SupabaseClientProvider.shared compiles
- [ ] No "No such module 'Supabase'" errors

### Build:
- [ ] Clean build successful (Shift+Cmd+K)
- [ ] Build successful (Cmd+B)
- [ ] No Supabase-related compiler errors
- [ ] App runs on Simulator or Device (Cmd+R)

---

## 🐞 Common Issues & Fixes

### Issue 1: "No such module 'Supabase'"

**Cause:** Package not added or not linked to target

**Fix:**
1. Verify package in Project Navigator → "Package Dependencies"
2. If missing, add package (see Step 2)
3. If present:
   - Target → General → Frameworks, Libraries, and Embedded Content
   - Click **+** → Add "Supabase" framework
4. Clean build (Shift+Cmd+K) and rebuild (Cmd+B)

---

### Issue 2: "SUPABASE_URL is not configured"

**Cause:** Secrets.xcconfig format error or not included in build settings

**Fix:**
1. Open `Config/Secrets.xcconfig`
2. Verify format:
   ```xcconfig
   SUPABASE_URL = https:/$()/yourproject.supabase.co
   SUPABASE_PUBLISHABLE_KEY = eyJhbGciOiJI...
   ```
3. Check build settings:
   - Target → Build Settings
   - Search: "SUPABASE_URL"
   - Should show value from xcconfig
4. Clean build and rebuild

---

### Issue 3: Package Resolution Fails

**Cause:** Network issue or package server problem

**Fix:**
1. Check internet connection
2. Try again: File → Add Package Dependencies
3. If still fails:
   - Delete Derived Data (Xcode → Settings → Locations → Derived Data)
   - Restart Xcode
   - Try again

---

### Issue 4: Build Errors After Adding Package

**Cause:** Cached build artifacts

**Fix:**
```bash
# Complete clean:
1. Quit Xcode
2. Delete Derived Data:
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
3. Reopen project
4. Clean build (Shift+Cmd+K)
5. Rebuild (Cmd+B)
```

---

### Issue 5: "Multiple commands produce..." or duplicate symbol errors

**Cause:** Multiple Supabase client providers or duplicate files

**Fix:**
1. Search project for duplicate `SupabaseClientProvider` classes
2. Ensure only ONE instance in: `Core/Supabase/SupabaseClientProvider.swift`
3. Remove any duplicates
4. Clean build and rebuild

---

## 📁 File Structure

After setup, your project should have:

```
Investor Tool/
├── Core/
│   └── Supabase/                          ← NEW LOCATION
│       ├── SupabaseClientProvider.swift   ← Moved here
│       └── SupabaseCompileCheck.swift     ← New file (DEBUG only)
├── Config/
│   ├── Secrets.xcconfig                   ← Fixed format
│   └── Secrets.example.xcconfig           ← Template
└── Features/
    └── Auth/
        ├── AuthViewModel.swift            ← Uses SupabaseClientProvider.shared
        └── ...

Project Dependencies:
└── Package Dependencies
    └── supabase-swift                     ← Added via Xcode
```

---

## 🚀 What to Do in Xcode Now - 5 Steps

### 1. Add Supabase Package
- File → Add Package Dependencies
- URL: `https://github.com/supabase-community/supabase-swift`
- Target: Investor Tool
- Products: Supabase (+ Auth, PostgREST, Storage, Functions)

### 2. Verify Package
- Check Project Navigator → "Package Dependencies" → supabase-swift appears
- Check Target → General → Frameworks list includes Supabase

### 3. Clean Build
- Product → Clean Build Folder (Shift+Cmd+K)

### 4. Build
- Product → Build (Cmd+B)
- Fix any errors (should be none if package added correctly)

### 5. Run
- Product → Run (Cmd+R)
- App should launch without Supabase errors
- Check console for: "✅ Supabase module linked successfully" (DEBUG builds)

---

## ✨ Success Criteria

**You're done when:**
- ✅ Package appears in Xcode Project Navigator
- ✅ `import Supabase` has no errors
- ✅ Build succeeds (Cmd+B)
- ✅ App runs without crashes (Cmd+R)
- ✅ No "SUPABASE CONFIGURATION ERROR" in console

**Next:** Your Supabase integration is ready! Proceed to authentication testing.

---

## 📞 Still Having Issues?

1. **Check package URL:** `https://github.com/supabase-community/supabase-swift`
2. **Verify Xcode version:** 15.0+ required
3. **Check iOS deployment target:** 15.0+ required
4. **Delete Derived Data** and try again
5. **Restart Xcode** and try again

---

**Documentation:**
- Supabase Swift SDK: https://github.com/supabase-community/supabase-swift
- Supabase Docs: https://supabase.com/docs
