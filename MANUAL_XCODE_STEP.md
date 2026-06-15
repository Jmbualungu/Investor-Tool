# Manual Xcode Step: Add Supabase Swift Package

**Status:** ⚠️ **REQUIRED** - Supabase SPM package is NOT currently added to the project.

---

## Steps to Add Supabase Swift Package

### 1. Open Project in Xcode
```bash
open "Investor Tool.xcodeproj"
```

### 2. Add Package Dependency

1. In Xcode, go to **File** → **Add Package Dependencies...**
   
2. In the search field (top-right), paste:
   ```
   https://github.com/supabase-community/supabase-swift
   ```

3. Select **supabase-swift** from the results

4. For "Dependency Rule", select **Up to Next Major Version**
   - Should show: `2.0.0 < 3.0.0` (or similar)

5. Click **Add Package**

6. In the "Add to Target" dialog:
   - ✅ Check **Investor Tool** (your app target)
   - Select these products:
     - ✅ **Supabase** (main package)
     - ✅ **Auth** (optional but recommended)
     - ✅ **PostgREST** (optional but recommended)
     - ✅ **Storage** (optional but recommended)
     - ✅ **Functions** (optional but recommended)

7. Click **Add Package**

### 3. Wait for Package Resolution
Xcode will download and resolve the package dependencies. This may take 1-2 minutes.

### 4. Verify Installation

**Check in Project Navigator:**
1. Expand "Investor Tool" project in left sidebar
2. Look for "Package Dependencies" section
3. Verify **supabase-swift** appears there

**Check in Build Phases:**
1. Select target "Investor Tool"
2. Go to **Build Phases** tab
3. Expand **Link Binary With Libraries**
4. Verify these frameworks are listed:
   - Supabase
   - Auth
   - PostgREST
   - Storage
   - Functions
   - (and their dependencies)

---

## After Adding Package

Once the package is added, proceed to:
- **SUPABASE_SETUP_CHECKLIST.md** for complete setup verification

---

## Troubleshooting

### "Package not found" or network error:
- Check internet connection
- Verify URL is correct: `https://github.com/supabase-community/supabase-swift`
- Try again in a few minutes

### Package added but import fails:
- Clean build: **Product** → **Clean Build Folder** (Shift+Cmd+K)
- Rebuild: **Product** → **Build** (Cmd+B)

### Multiple package errors:
- Delete **Derived Data**: 
  - Xcode → Settings → Locations → Derived Data → Click arrow → Delete folder
- Restart Xcode
- Try adding package again

---

## Quick Reference

**Package URL:**
```
https://github.com/supabase-community/supabase-swift
```

**Target:** Investor Tool

**Products to Add:**
- Supabase (required)
- Auth, PostgREST, Storage, Functions (recommended)

---

**Next Step:** After adding package, follow **SUPABASE_SETUP_CHECKLIST.md**
