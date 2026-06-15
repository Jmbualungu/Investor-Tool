# Device Manual Setup Steps - Quick Reference

## 🚨 CRITICAL: Manual Steps Required Before Testing on Real iPhone

These steps **MUST** be performed manually in Xcode before the auth system will work on a physical device.

---

## Step 1: Fill Secrets.xcconfig

**File:** `Investor Tool/Config/Secrets.xcconfig`

**Action:** Replace placeholder values with your real Supabase credentials:

```xcconfig
SUPABASE_URL = https:/$()/your-actual-project-id.supabase.co
SUPABASE_PUBLISHABLE_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your_actual_anon_key_here
```

**Where to get these:**
- Open https://app.supabase.com
- Select your project
- Go to Settings → API
- Copy "Project URL" → paste as SUPABASE_URL
- Copy "anon public" key → paste as SUPABASE_PUBLISHABLE_KEY

---

## Step 2: Verify URL Scheme in Xcode

**Action:** Confirm `augur://` URL scheme is registered:

1. Open project in Xcode
2. Select target: **Investor Tool**
3. Click **Info** tab
4. Scroll to **URL Types** section
5. Expand to verify:
   - **Identifier**: `auth`
   - **URL Schemes**: `augur`

**Visual Guide:**
```
URL Types
  └─ Item 0
      ├─ Identifier: auth
      ├─ URL Schemes: augur
      └─ Role: Editor
```

**If missing:**
- Click **+** under URL Types
- Identifier: `auth`
- URL Schemes: `augur`
- Role: Editor

---

## Step 3: Clean Build

**Action:** Clean build folder to ensure new configuration is loaded:

**Option A (Keyboard):**
- Press `Cmd+Shift+K`

**Option B (Menu):**
- Product → Clean Build Folder

---

## Step 4: Rebuild

**Action:** Rebuild the app:

**Option A (Keyboard):**
- Press `Cmd+B`

**Option B (Menu):**
- Product → Build

---

## Step 5: Install on Device

**Action:** Connect iPhone and install:

1. Connect iPhone to Mac via USB
2. Unlock iPhone and trust computer if prompted
3. In Xcode, select your iPhone from device dropdown (top toolbar)
4. Press `Cmd+R` to build and run on device

**Device must be:**
- ✅ Physically connected via USB (first time)
- ✅ Unlocked
- ✅ "Trust This Computer" accepted
- ✅ Developer mode enabled (iOS 16+)

---

## Step 6: Test Deep Link (Safari)

**Action:** Verify deep link works on device:

1. On your iPhone, open **Safari**
2. In address bar, type: `augur://auth-callback`
3. Press **Go**
4. **Expected:** App opens immediately

**If app doesn't open:**
- Reinstall app (sometimes required for URL scheme changes)
- Restart iPhone
- Verify URL scheme in Xcode (Step 2)

---

## Step 7: Test Password Reset Flow

**Action:** Full end-to-end test:

1. Launch app on iPhone
2. Sign up or sign in
3. Sign out
4. Tap "Forgot Password?"
5. Enter your email (use an email you can check **on the iPhone**)
6. Tap "Send Reset Link"
7. Open email **on the iPhone**
8. Tap the reset link in the email
9. **Expected:** App opens and shows UpdatePasswordView
10. Set new password
11. **Expected:** Success, you're signed in

---

## ✅ Verification Checklist

Before running tests, verify:

- [ ] `Config/Secrets.xcconfig` filled with real credentials
- [ ] URL scheme `augur` configured in Xcode → Target → Info → URL Types
- [ ] Clean build performed (Cmd+Shift+K)
- [ ] Rebuild performed (Cmd+B)
- [ ] iPhone connected and trusted
- [ ] App installed on iPhone (Cmd+R)
- [ ] Safari test: `augur://test` opens the app

---

## 🐞 Quick Debug

**If something doesn't work:**

1. **Check Xcode Console** (Cmd+Shift+Y)
   - Look for errors starting with ❌
   - Look for debug messages starting with 🔗, 🔐, ✅

2. **Check Debug Panel** (top-right corner in app)
   - Tap to expand
   - Verify auth state
   - Check "Last Deep Link" when testing deep links

3. **Verify Supabase Dashboard**
   - Auth → Users: Verify user exists
   - Auth → Logs: Check for errors
   - Auth → Settings → Redirect URLs: Verify `augur://auth-callback` is listed

---

## 📞 Common Issues

### **App crashes on launch:**
- **Cause:** Secrets.xcconfig not filled or incorrectly formatted
- **Fix:** Verify Step 1, clean build, rebuild

### **Deep link doesn't open app:**
- **Cause:** URL scheme not registered
- **Fix:** Verify Step 2, reinstall app, restart iPhone

### **Password reset email not received:**
- **Cause:** Email not configured in Supabase or wrong email entered
- **Fix:** Check Supabase Dashboard → Auth → Settings → Email Templates

### **UpdatePasswordView doesn't appear:**
- **Cause:** Deep link processing failed
- **Fix:** Check Xcode console for errors, verify redirect URL in Supabase

---

## 🎯 Success Criteria

**You're ready to test when:**
- App launches without crashing ✅
- Debug panel shows auth state ✅
- Safari test (`augur://test`) opens app ✅
- Sign up/sign in works ✅

**Full success when:**
- Password reset email arrives ✅
- Tapping email link opens app ✅
- UpdatePasswordView appears ✅
- New password is set successfully ✅
- Can sign in with new password ✅

---

## 🚀 Ready to Test?

If all steps above are complete, proceed to:
📄 **SUPABASE_AUTH_SETUP_GUIDE.md** → "🧪 Test Checklist" section
