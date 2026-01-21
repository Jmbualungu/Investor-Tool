# Supabase Key Rotation Guide

## ⚠️ CRITICAL: Your Publishable Key Was Exposed

**Exposed Key:** `sb_publishable_o2XdhFDbooCbUyV6mtuN1Q_dVAm4-7U`  
**Project URL:** `https://udttgzeuzmuzkcqogegy.supabase.co`

This key must be rotated immediately.

---

## Step 1: Generate New Publishable Key (Anon Key)

**Click-Path in Supabase Dashboard:**

1. Go to: https://app.supabase.com/project/udttgzeuzmuzkcqogegy
2. Click: **Settings** (gear icon in left sidebar)
3. Click: **API** (under "Project Settings")
4. Scroll to: **Project API keys** section
5. Find: **anon** **public** key (this is your "publishable key")
6. Click: **Regenerate** button next to the anon key
7. Confirm regeneration in the modal
8. **Copy the new key immediately** (it will look like: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

**Important Notes:**
- The **anon key** (also called "publishable key") is safe to embed in client apps
- It has Row-Level Security (RLS) enforced
- Regenerating invalidates the old key immediately

---

## Step 2: Invalidate Old Key

**The old key is automatically invalidated when you regenerate.**

To verify:
1. After regeneration, try using the old key in a test request
2. You should get a `401 Unauthorized` error
3. The new key should work immediately

---

## Step 3: Update Local Config

Once you have the new key, paste it into:

```
Investor Tool/Config/Secrets.xcconfig
```

Format:
```
SUPABASE_URL = https:/$()/udttgzeuzmuzkcqogegy.supabase.co
SUPABASE_PUBLISHABLE_KEY = <PASTE_NEW_KEY_HERE>
```

**Never commit this file to git!** (It's in .gitignore)

---

## Step 4: Verify Key Types

In the Supabase Dashboard → Settings → API, you'll see:

- ✅ **anon key** (Publishable) - Safe for iOS app
  - Use this in your iOS app
  - RLS is enforced
  - Can be embedded in app bundle

- ❌ **service_role key** (Secret) - NEVER use in iOS
  - Full database access
  - Bypasses RLS
  - Only for backend servers
  - NEVER embed in client apps

---

## Step 5: Update Production Keys

If you deploy to TestFlight or App Store:

1. Generate a new anon key for production (same steps above)
2. Use Xcode build configurations to separate dev/prod keys
3. See: `Config/Debug.xcconfig` and `Config/Release.xcconfig`

---

## Checklist

- [ ] Regenerate anon key in Supabase Dashboard
- [ ] Copy new key to `Config/Secrets.xcconfig`
- [ ] Verify old key no longer works
- [ ] Confirm `Secrets.xcconfig` is in `.gitignore`
- [ ] Never commit actual keys to git
- [ ] Never use `service_role` key in iOS app

---

**Reference:** See `Config/Secrets.example.xcconfig` for the template.
