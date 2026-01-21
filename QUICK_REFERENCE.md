# Quick Reference Card

One-page cheat sheet for Supabase integration in Investor Tool.

---

## 🔑 Where Are My Keys?

**Local (Development):**
- `Investor Tool/Config/Secrets.xcconfig` (gitignored)

**Production (To Be Set Up):**
- Same file, but with production Supabase project keys
- Use Xcode build configurations (Debug vs Release)

**Never:**
- ❌ Hardcode in Swift files
- ❌ Commit to git
- ❌ Use `service_role` key in iOS

---

## 🚀 Quick Commands

### Start Local Supabase

```bash
cd "Investor Tool"
supabase start

# Output includes:
# - API URL (use in iOS for local testing)
# - Studio URL (web UI)
# - anon key (for iOS)
```

### Deploy Edge Functions

```bash
# Deploy write-forecast-version (rate-limited writes)
supabase functions deploy write-forecast-version

# View logs
supabase functions logs write-forecast-version
```

### Run SQL Migration

```bash
# Option 1: Via Dashboard (recommended for first time)
# Copy PASTE_INTO_SUPABASE_SQL_EDITOR.sql → SQL Editor → Run

# Option 2: Via CLI (if you've run supabase init)
supabase db push
```

---

## 🏗️ Schema Overview

| Table | Purpose | RLS Policy |
|-------|---------|------------|
| `profiles` | User metadata | `id = auth.uid()` |
| `watchlists` | Tracked tickers | `user_id = auth.uid()` |
| `forecasts` | Valuation models | `user_id = auth.uid()` |
| `forecast_versions` | Versioned assumptions | `user_id = auth.uid()` + forecast ownership |
| `rate_limits` | Rate limiting counters | Service role only |

---

## 🛡️ Security Checklist

**Before every commit:**
```bash
# Verify secrets not committed
git status  # Should not show Secrets.xcconfig

# Verify no hardcoded keys
grep -r "sb_publishable" "Investor Tool"/*.swift
grep -r "udttgzeuzmuzkcqogegy" "Investor Tool"/*.swift
# Should return: no matches
```

**After key rotation:**
1. Regenerate anon key in Dashboard → Settings → API
2. Paste new key into `Config/Secrets.xcconfig`
3. Clean build (Cmd+Shift+K)
4. Rebuild (Cmd+B)

---

## 🧪 Testing

### Test Auth

```swift
// Sign up
let session = try await supabase.auth.signUp(email: "test@example.com", password: "password123")

// Sign in
let session = try await supabase.auth.signIn(email: "test@example.com", password: "password123")

// Get current session
let session = try await supabase.auth.session
```

### Test Database

```swift
// Insert watchlist
try await supabase.database
    .from("watchlists")
    .insert(["user_id": userId, "ticker": "AAPL"])
    .execute()

// Read watchlist
let watchlist: [WatchlistRow] = try await supabase.database
    .from("watchlists")
    .select()
    .execute()
    .value
```

### Test Edge Function

```swift
struct VersionRequest: Encodable {
    let forecast_id: UUID
    let assumptions: [String: String]
}

let request = VersionRequest(
    forecast_id: forecastId,
    assumptions: ["growth_rate": "0.05"]
)

try await supabase.functions.invoke(
    "write-forecast-version",
    options: FunctionInvokeOptions(body: request)
)
```

### Run Smoke Tests

1. Launch app
2. Sign in
3. Navigate to Backend Status (debug menu)
4. Tap "Run All Tests"
5. Check for ✅ (all pass)

---

## 🚦 Rate Limiting

### Platform Limits (Supabase Dashboard)

**Settings → API → Rate Limiting:**
- 100 requests/second
- 1000 requests/minute
- 10000 requests/hour

**Settings → Auth → Rate Limits:**
- 5 sign-ups/hour
- 20 sign-ins/hour

### Application Limits (Edge Functions)

**write-forecast-version:**
- 5 writes/minute per user
- 30 writes/5 minutes per user
- Returns 429 with `Retry-After` header

---

## 📁 Key Files

| File | Purpose |
|------|---------|
| `Config/Secrets.xcconfig` | Actual keys (gitignored) |
| `Config/Secrets.example.xcconfig` | Template (safe to commit) |
| `Core/Services/SupabaseClientProvider.swift` | Singleton client |
| `Features/Auth/AuthView.swift` | Sign in/up UI |
| `Features/Debug/BackendStatusView.swift` | Smoke tests |
| `supabase/migrations/20260120_initial_schema_with_rls.sql` | Database schema |
| `supabase/functions/write-forecast-version/index.ts` | Rate-limited writes |

---

## 🆘 Common Errors

### "SUPABASE_URL is not configured"

**Fix:**
1. Open `Config/Secrets.xcconfig`
2. Replace `PASTE_YOUR_NEW_ANON_KEY_HERE` with actual key
3. Clean build (Cmd+Shift+K)
4. Rebuild (Cmd+B)

### "No such module 'Supabase'"

**Fix:**
1. File → Add Package Dependencies...
2. Add: `https://github.com/supabase/supabase-swift`

### SQL migration fails

**Fix:**
1. Check you're logged in as project owner
2. Run script in sections (copy one CREATE TABLE at a time)
3. Check error message for specific issue

### Edge Function returns 500

**Fix:**
```bash
supabase functions logs write-forecast-version
# Check for errors
```

Common issues:
- Function not deployed: `supabase functions deploy write-forecast-version`
- Wrong environment: Verify using correct Supabase project

### Smoke test fails

**Test 1 (Auth):** Sign in first  
**Test 2 (Watchlist):** Run SQL migration  
**Test 3 (Forecast):** Deploy Edge Function

---

## 📚 Full Documentation

| Guide | Purpose |
|-------|---------|
| `SUPABASE_INTEGRATION_COMPLETE.md` | Complete overview + checklist |
| `SUPABASE_KEY_ROTATION_GUIDE.md` | Rotate exposed keys |
| `XCODE_SETUP_GUIDE.md` | Configure Xcode |
| `RATE_LIMITING_GUIDE.md` | Platform + app rate limits |
| `PASTE_INTO_SUPABASE_SQL_EDITOR.sql` | Ready-to-paste schema |
| `supabase/README.md` | Supabase project docs |

---

## 🎯 Setup Checklist (20 Minutes)

- [ ] **Rotate key** (5 min)
  - Dashboard → Settings → API → Regenerate anon key
  - Paste into `Config/Secrets.xcconfig`

- [ ] **Configure Xcode** (5 min)
  - Link xcconfig files (Debug/Release)
  - Update Info.plist
  - Add Supabase package

- [ ] **Run SQL migration** (2 min)
  - Copy `PASTE_INTO_SUPABASE_SQL_EDITOR.sql`
  - Paste in Dashboard → SQL Editor → Run

- [ ] **Deploy Edge Functions** (3 min)
  - `supabase functions deploy write-forecast-version`

- [ ] **Test in app** (5 min)
  - Sign up test user
  - Run smoke tests in Backend Status
  - Verify all ✅

---

**Status:** Ready for production after completing checklist. 🚀
