# Xcode Project Setup Guide

Complete instructions for configuring Xcode to use xcconfig files for safe secret management.

---

## Step 1: Add Supabase Swift Package

1. Open `Investor Tool.xcodeproj` in Xcode
2. Go to: **File → Add Package Dependencies...**
3. Enter URL: `https://github.com/supabase/supabase-swift`
4. Version: Select "Up to Next Major Version" with `2.0.0`
5. Click **Add Package**
6. Select these products to add:
   - ✅ **Supabase**
   - ✅ **Auth**
   - ✅ **PostgREST**
   - ✅ **Functions**
   - ✅ **Storage**
7. Click **Add Package**

---

## Step 2: Configure Build Settings with xcconfig Files

### 2.1: Add Config Files to Project

1. In Xcode, right-click on `Investor Tool` folder (blue folder icon)
2. Select: **Add Files to "Investor Tool"...**
3. Navigate to: `Investor Tool/Config/`
4. Select all `.xcconfig` files:
   - `Debug.xcconfig`
   - `Release.xcconfig`
   - `Secrets.example.xcconfig`
5. **Uncheck** "Copy items if needed" (they're already in the right place)
6. Click **Add**

**Important:** Do NOT add `Secrets.xcconfig` to the Xcode project. It should only exist on disk (gitignored).

### 2.2: Link xcconfig to Project Settings

1. In Xcode, select the **project** (blue "Investor Tool" icon at the top of the navigator)
2. Select the **Investor Tool** project (not the target) in the center pane
3. Click on the **Info** tab
4. Under **Configurations**, you'll see:
   - Debug
   - Release

5. For **Debug**:
   - Click on "Investor Tool" under "Based on configuration file"
   - Select: **Debug** (from the dropdown)

6. For **Release**:
   - Click on "Investor Tool" under "Based on configuration file"
   - Select: **Release** (from the dropdown)

### 2.3: Verify Configuration

1. Select the **Investor Tool target** (app icon, under project)
2. Go to: **Build Settings** tab
3. Search for: `SUPABASE`
4. You should see:
   - `SUPABASE_URL`
   - `SUPABASE_PUBLISHABLE_KEY`
5. The values should show as defined (not empty)

---

## Step 3: Update Info.plist

The Info.plist needs to expose build settings as app configuration.

### 3.1: Open Info.plist

1. In Xcode navigator, find: `Info.plist`
2. Right-click → **Open As → Source Code**

### 3.2: Add Supabase Configuration Keys

Add these lines inside the `<dict>` tag (before `</dict>`):

```xml
<!-- Supabase Configuration -->
<key>SUPABASE_URL</key>
<string>$(SUPABASE_URL)</string>
<key>SUPABASE_PUBLISHABLE_KEY</key>
<string>$(SUPABASE_PUBLISHABLE_KEY)</string>
```

**Full example:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<!-- ... existing keys ... -->
	
	<!-- Supabase Configuration -->
	<key>SUPABASE_URL</key>
	<string>$(SUPABASE_URL)</string>
	<key>SUPABASE_PUBLISHABLE_KEY</key>
	<string>$(SUPABASE_PUBLISHABLE_KEY)</string>
</dict>
</plist>
```

### 3.3: Save and Close

1. Save the file (Cmd+S)
2. Switch back to **Open As → Property List** for easier viewing

---

## Step 4: Paste Your Actual Keys

1. Open: `Investor Tool/Config/Secrets.xcconfig` in a text editor
2. Follow the key rotation guide: `SUPABASE_KEY_ROTATION_GUIDE.md`
3. Replace placeholders with your actual values:

```
SUPABASE_URL = https:/$()/YOUR_ACTUAL_PROJECT_ID.supabase.co
SUPABASE_PUBLISHABLE_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.YOUR_ACTUAL_ANON_KEY
```

4. Save the file

---

## Step 5: Add Config Directory to Xcode Groups

To keep the project organized:

1. In Xcode, right-click on `Investor Tool` folder
2. Select: **New Group**
3. Name it: `Config`
4. Drag the visible `.xcconfig` files into this group:
   - `Debug.xcconfig`
   - `Release.xcconfig`
   - `Secrets.example.xcconfig`

**Note:** `Secrets.xcconfig` should NOT appear in Xcode (it's gitignored).

---

## Step 6: Clean Build and Test

1. Clean Build Folder: **Product → Clean Build Folder** (or Cmd+Shift+K)
2. Build: **Product → Build** (or Cmd+B)
3. Check for errors:
   - If you see "SUPABASE_URL is not configured" error → check Step 4
   - If build succeeds → configuration is correct!

---

## Step 7: Verify Configuration in App

1. Run the app (Cmd+R)
2. If the app crashes with a configuration error:
   - Read the error message carefully
   - It will tell you exactly what's missing
   - Usually means `Secrets.xcconfig` has placeholder values

3. If the app runs without crashing:
   - ✅ Configuration is correct!
   - You can now use `SupabaseClientProvider.shared`

---

## Troubleshooting

### Error: "SUPABASE_URL is not configured"

**Cause:** Xcode can't find the values from xcconfig files.

**Fix:**
1. Verify xcconfig files are linked (Step 2.2)
2. Verify `Secrets.xcconfig` exists at: `Investor Tool/Config/Secrets.xcconfig`
3. Verify `Secrets.xcconfig` has actual values (not placeholders)
4. Clean build folder (Cmd+Shift+K) and rebuild

### Error: "No such module 'Supabase'"

**Cause:** Supabase Swift SDK not added.

**Fix:**
1. Go to: **File → Add Package Dependencies...**
2. Add: `https://github.com/supabase/supabase-swift`

### xcconfig file not found

**Cause:** File path is wrong or file doesn't exist.

**Fix:**
1. Verify files exist at: `Investor Tool/Config/`
2. Check file paths in Debug.xcconfig and Release.xcconfig
3. Ensure `#include "Secrets.xcconfig"` is correct (relative path)

### Values still showing as placeholders

**Cause:** `Secrets.xcconfig` contains placeholder text.

**Fix:**
1. Open `Secrets.xcconfig` in a text editor
2. Replace `PASTE_YOUR_NEW_ANON_KEY_HERE` with actual anon key from Supabase Dashboard
3. Save and clean build

---

## Security Checklist

After setup, verify:

- ✅ `Secrets.xcconfig` is in `.gitignore`
- ✅ `Secrets.xcconfig` does NOT appear in Xcode project navigator
- ✅ `Secrets.example.xcconfig` is committed to git (safe template)
- ✅ Actual keys are only in `Secrets.xcconfig` (gitignored)
- ✅ No keys hardcoded in Swift files
- ✅ `git status` shows no uncommitted changes to `Secrets.xcconfig`

---

## Next Steps

Once Xcode is configured:

1. ✅ Run the SQL migration in Supabase SQL Editor
2. ✅ Deploy the Edge Function: `supabase functions deploy write-forecast-version`
3. ✅ Test auth flow in the app
4. ✅ Run smoke tests in Backend Status screen

See: `SUPABASE_INTEGRATION_COMPLETE.md` for full checklist.
