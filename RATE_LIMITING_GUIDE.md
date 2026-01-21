# Rate Limiting Configuration Guide

Comprehensive guide for configuring rate limiting at both platform and application levels.

---

## Overview

Rate limiting is implemented in **two layers**:

1. **Platform Level** (Supabase Dashboard) - Controls API access
2. **Application Level** (Edge Functions) - Controls write-heavy operations

---

## Layer 1: Platform-Level Rate Limiting (Supabase Dashboard)

### Step 1: Access Rate Limiting Settings

**Click-Path:**

1. Go to: https://app.supabase.com/project/udttgzeuzmuzkcqogegy
2. Click: **Settings** (gear icon in left sidebar)
3. Click: **API** (under "Project Settings")
4. Scroll to: **Rate Limiting** section

### Step 2: Configure API Rate Limits

**Recommended Settings for Production:**

| Setting | Recommended Value | Reasoning |
|---------|------------------|-----------|
| **Requests per second (per IP)** | 100 | Generous for normal usage, blocks DoS |
| **Requests per minute (per IP)** | 1000 | Allows bursts, limits sustained abuse |
| **Requests per hour (per IP)** | 10000 | Daily limit safety net |
| **Anonymous requests per hour** | 500 | Lower limit for unauthenticated users |

**How to Set:**

1. In **Rate Limiting** section, find each setting
2. Click **Edit** or enter value in input field
3. Click **Save** after each change

### Step 3: Configure Auth Rate Limits

**Click-Path:**

1. Settings → **Auth** (under "Project Settings")
2. Scroll to: **Rate Limits** section

**Recommended Settings:**

| Setting | Recommended Value | Reasoning |
|---------|------------------|-----------|
| **Sign-ups per hour (per IP)** | 5 | Prevents automated account creation |
| **Sign-ins per hour (per IP)** | 20 | Allows retries, blocks brute force |
| **Password resets per hour (per IP)** | 3 | Limits reset spam |
| **Email verifications per hour** | 5 | Prevents email bombing |

### Step 4: Enable Abuse Prevention

**Click-Path:**

1. Settings → **Auth** → **Abuse Prevention** section
2. Toggle **ON**: "Enable abuse prevention"

**What it does:**
- Blocks suspicious patterns (rapid sign-ups from same IP)
- Requires CAPTCHA for suspicious requests
- Automatically bans IPs with repeated violations

---

## Layer 2: Application-Level Rate Limiting (Edge Functions)

### Implemented in: `write-forecast-version` Edge Function

**Limits Enforced:**

| Window | Max Requests | Purpose |
|--------|--------------|---------|
| 1 minute | 5 | Prevents rapid-fire abuse |
| 5 minutes | 30 | Limits sustained bursts |

**How It Works:**

1. User calls Edge Function with auth token
2. Function extracts user ID from JWT
3. Checks `rate_limits` table for current window counts
4. If limit exceeded → returns `429 Too Many Requests`
5. If allowed → inserts data and increments counter

**Response on Limit Exceeded:**

```json
{
  "error": "Rate limit exceeded",
  "message": "Too many requests. Maximum 5 per 1 minute(s).",
  "retryAfter": 42
}
```

**Headers:**
- `Retry-After: 42` (seconds until window resets)
- `Status: 429 Too Many Requests`

### Adjusting Rate Limits

Edit: `supabase/functions/write-forecast-version/index.ts`

```typescript
const RATE_LIMITS: RateLimitConfig[] = [
  { key: 'write-forecast-version-5min', maxCount: 30, windowMinutes: 5 },
  { key: 'write-forecast-version-1min', maxCount: 5, windowMinutes: 1 },
]
```

**Recommendations:**

- **Development:** Increase limits for testing (e.g., 100/5min, 20/1min)
- **Production:** Start conservative, increase based on usage patterns
- **Premium Users:** Consider separate limits (e.g., `maxCount: 100` for paid tier)

### Deploying Changes

```bash
cd "Investor Tool"
supabase functions deploy write-forecast-version
```

---

## Layer 3: Database-Level Rate Limiting (PostgREST)

### Current Implementation

Direct database access (via PostgREST) is **not rate-limited** at the application level, but:

1. **RLS enforces user isolation** (users can only access their own data)
2. **Platform rate limits apply** (requests per second/minute from Supabase Dashboard)
3. **Read operations are fast** (indexed queries, low abuse risk)

### When to Add Application-Level Limits

Consider adding Edge Functions for rate-limiting if:

- ❌ Users can trigger expensive queries (full table scans, complex joins)
- ❌ Write operations lack validation (bulk inserts without constraints)
- ❌ Analytics show abuse patterns (single user making 1000s of requests)

For **Investor Tool**, reads are simple (forecasts, watchlists) and writes are protected by Edge Functions → **No additional limits needed.**

---

## Monitoring Rate Limit Violations

### Supabase Dashboard

**Click-Path:**

1. Project → **Logs** (in left sidebar)
2. Select: **API** logs
3. Filter by: `status_code = 429`

**What to Look For:**

- Frequent 429 errors from same IP → Potential abuse
- 429 errors on auth endpoints → Brute force attempt
- Legitimate users hitting limits → Consider increasing limits

### Application Logs (Edge Functions)

**View logs:**

```bash
supabase functions logs write-forecast-version
```

**What to Look For:**

```
Rate limit exceeded for user: <user_id>
```

**Action:**
- Investigate user behavior
- Check if legitimate (increase limits) or abuse (ban user)

---

## Testing Rate Limits

### Test Platform Limits

```bash
# Send 150 requests rapidly (should get 429 after ~100)
for i in {1..150}; do
  curl -X GET "https://udttgzeuzmuzkcqogegy.supabase.co/rest/v1/forecasts" \
    -H "apikey: YOUR_ANON_KEY" \
    -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
done
```

### Test Edge Function Limits

```swift
// In iOS smoke tests, call write-forecast-version 10 times rapidly
// Expected: First 5 succeed, next 5 get 429

Task {
    for i in 1...10 {
        do {
            try await supabase.functions.invoke("write-forecast-version", options: ...)
            print("✅ Request \(i) succeeded")
        } catch {
            print("❌ Request \(i) failed: \(error)")
        }
    }
}
```

---

## Rate Limit Cleanup

Rate limit counters are stored in `rate_limits` table. Old windows should be cleaned periodically.

### Manual Cleanup (SQL Editor)

```sql
SELECT cleanup_old_rate_limits();
```

### Automated Cleanup (Recommended)

**Option 1: Supabase Cron Job (if available)**

```sql
-- Run every hour
SELECT cron.schedule(
  'cleanup-rate-limits',
  '0 * * * *',
  $$SELECT cleanup_old_rate_limits()$$
);
```

**Option 2: Edge Function Scheduled Task**

Create: `supabase/functions/cleanup-rate-limits/index.ts`

```typescript
serve(async (req) => {
  const supabase = createClient(...)
  await supabase.rpc('cleanup_old_rate_limits')
  return new Response(JSON.stringify({ ok: true }), { status: 200 })
})
```

Deploy:
```bash
supabase functions deploy cleanup-rate-limits
```

Schedule via external cron (e.g., GitHub Actions, AWS Lambda):
```bash
curl -X POST https://udttgzeuzmuzkcqogegy.supabase.co/functions/v1/cleanup-rate-limits
```

---

## Production Checklist

Before launch:

- [ ] Platform rate limits configured in Supabase Dashboard
- [ ] Auth rate limits enabled
- [ ] Abuse prevention enabled
- [ ] Edge Function rate limits tested
- [ ] Monitoring set up for 429 errors
- [ ] Cleanup job scheduled (manual or automated)
- [ ] Rate limit documentation shared with team
- [ ] Client-side error handling for 429 responses

---

## Client-Side Error Handling (iOS)

When calling Edge Functions, handle 429 errors gracefully:

```swift
do {
    let response = try await supabase.functions.invoke("write-forecast-version", ...)
} catch {
    if let httpError = error as? HTTPError, httpError.statusCode == 429 {
        // Extract retry-after from error
        let retryAfter = httpError.headers["Retry-After"] ?? "60"
        
        // Show user-friendly message
        showError("You're doing that too often. Please wait \(retryAfter) seconds.")
    } else {
        // Other error
        showError(error.localizedDescription)
    }
}
```

---

## Summary

**Platform Level (Supabase Dashboard):**
- ✅ Protects against DoS and brute force
- ✅ Applies to all API requests (auth, database, storage)
- ✅ Easy to configure, no code changes needed

**Application Level (Edge Functions):**
- ✅ Granular control per endpoint
- ✅ Per-user limits (not just per-IP)
- ✅ Custom logic (e.g., different limits for premium users)

**Best Practice:**
- Use **both layers** for defense in depth
- Start **conservative**, increase based on real usage
- **Monitor** 429 errors and adjust accordingly
- **Communicate** limits to users (e.g., "Max 30 saves per 5 minutes")

---

**Next:** Deploy Edge Function and test rate limits in Backend Status screen.
