# OTP-First Authentication UX Spec

**Product:** ForecastAI iOS App  
**Auth Provider:** Supabase Auth  
**Primary Flow:** Email + OTP (Passwordless)  
**Design Inspiration:** Robinhood-like simplicity

---

## A) Product UX (OTP-First)

### Screen 1: Email Entry

**Purpose:** Capture user's email address to send OTP code.

**UI Elements:**

```
┌─────────────────────────────────────┐
│                                     │
│         [App Logo/Branding]         │
│                                     │
│    Welcome to ForecastAI            │
│    Get started with your email      │
│                                     │
│    ┌─────────────────────────────┐  │
│    │ Email                       │  │
│    │ you@example.com             │  │
│    └─────────────────────────────┘  │
│                                     │
│    ┌─────────────────────────────┐  │
│    │      Send code              │  │ <- Primary button
│    └─────────────────────────────┘  │
│                                     │
│    By continuing, you agree to our  │
│    Terms of Service and Privacy     │
│    Policy                           │
│                                     │
└─────────────────────────────────────┘
```

**Microcopy:**
- Heading: "Get a 6-digit code"
- Subheading: "We'll send it to your email"
- Button: "Send code"
- Input placeholder: "you@example.com"

**Behavior:**
- Email validation (basic format check: `@` and `.`)
- Button disabled until valid email entered
- On tap "Send code":
  - Show loading state on button
  - Call `supabase.auth.signInWithOtp({ email })`
  - On success: navigate to Screen 2
  - On error: show inline error (e.g., "Invalid email" or "Too many attempts")

**Error States:**
- Invalid email format: "Please enter a valid email address"
- Rate limit exceeded: "Too many attempts. Please try again in 5 minutes."
- Network error: "Couldn't connect. Check your internet connection."

---

### Screen 2: OTP Code Entry

**Purpose:** Verify user owns the email by entering the 6-digit code sent to their inbox.

**UI Elements:**

```
┌─────────────────────────────────────┐
│                                     │
│    Check your email                 │
│                                     │
│    We sent a code to:               │
│    user@example.com                 │
│                                     │
│    ┌───┬───┬───┬───┬───┬───┐        │
│    │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │        │ <- 6-digit input
│    └───┴───┴───┴───┴───┴───┘        │
│                                     │
│    Resend code in 0:42              │ <- Timer + resend
│                                     │
│    Try a different email            │ <- Back to Screen 1
│                                     │
└─────────────────────────────────────┘
```

**Microcopy:**
- Heading: "Check your email"
- Body: "We sent a code to [email]"
- Timer: "Resend code in 0:XX" (countdown from 60s)
- Resend link (after timer): "Resend code"
- Back link: "Try a different email"

**Behavior:**
- Auto-focus on first digit input
- Auto-advance to next digit on entry
- Auto-submit when all 6 digits entered (no separate button needed)
- Call `supabase.auth.verifyOtp({ email, token, type: 'email' })`
- On success:
  - Store session securely (Keychain recommended for iOS)
  - Route to AppShell (Forecast tab)
- On failure:
  - Show inline error
  - Clear inputs
  - Allow retry

**Timer Logic:**
- Start 60-second countdown when screen loads
- Show "Resend code" link after timer expires
- On resend:
  - Reset timer to 60s
  - Call `signInWithOtp` again
  - Show toast: "Code sent!"

**Error States:**
- Invalid code: "Invalid code. Please try again."
- Expired code: "Code expired. Tap 'Resend code' to get a new one."
- Too many failed attempts: "Too many attempts. Please request a new code."
- Network error: "Couldn't verify code. Check your connection."

---

### Success State: Navigate to App

**Behavior:**
- Session stored in Keychain (or equivalent secure storage)
- Access token automatically attached to Supabase client for DB reads/writes
- User routed to main app (AppShell, default tab: Forecast)
- Show optional welcome toast: "Welcome to ForecastAI!" (first-time users only)

---

### Fallback: Return to Email Entry

**Trigger:** User taps "Try a different email" on Screen 2

**Behavior:**
- Navigate back to Screen 1
- Clear previous email from input (or pre-fill for editing)
- No error message shown (user intentionally went back)

---

## B) Supabase Settings Checklist (Dashboard)

### Authentication → Providers → Email

**Required Settings:**

- ✅ **Enable Email Provider**
  - Navigate to: Dashboard → Authentication → Providers
  - Toggle ON: "Email"

- ✅ **Enable Email OTP / Passwordless**
  - Under Email provider settings
  - Toggle ON: "Enable Email OTP"
  - Reasoning: This is the primary auth method (no passwords).

- ✅ **OTP Length: 6 digits**
  - Default is usually 6; verify this setting
  - Reasoning: Industry standard (matches banking apps, 2FA flows); easy to read from email; fits well in UI (6-box input).

- ✅ **OTP Expiry: 10 minutes**
  - Recommendation: 10 minutes (600 seconds)
  - Reasoning:
    - Long enough: User may need to switch apps, check spam, wait for delivery
    - Short enough: Reduces window for brute-force or code reuse attacks
    - Fallback: User can always request a new code via "Resend"

- ✅ **Email Confirmations: OFF for OTP flow**
  - Setting: "Confirm email" → DISABLED
  - Reasoning:
    - OTP flow already proves inbox access (user must retrieve code from email)
    - Enabling this would require TWO emails: confirmation link + OTP code (redundant)
    - OTP verification is stronger proof than clicking a link (typing 6 digits requires active engagement)
  - **Exception:** If you later add magic link (email-only) as a fallback, you may want confirmations ON for that flow. Keep OFF for OTP.

- ✅ **Site URL**
  - Set to your eventual domain (e.g., `https://forecastai.app`)
  - For local dev: `http://localhost:3000` (or any local URL)
  - Reasoning: Used in email template branding and links (if any). Not critical for OTP, but good hygiene.

- ✅ **Redirect URLs**
  - For OTP: Minimal (OTP doesn't rely on redirect like magic link)
  - Recommended: Add your production domain as allowed redirect (e.g., `https://forecastai.app/*`)
  - For local dev: Add `http://localhost:*` if testing magic links alongside OTP
  - Reasoning: OTP verification happens client-side (no redirect), but this setting is required for magic link fallback (if you add it later).

---

### Authentication → Rate Limits / Security

**Purpose:** Reduce abuse, brute-force, and spam.

**Recommended Settings:**

- ✅ **OTP Requests per Hour (per IP)**
  - Limit: 5–10 requests/hour
  - Reasoning: Legitimate user rarely needs more than 1–2 codes/hour. Higher limit (10) accounts for mistakes/retries. Blocks attackers spamming emails.

- ✅ **Verify Attempts per Hour (per IP)**
  - Limit: 20 attempts/hour
  - Reasoning: 6-digit OTP has 1,000,000 possible combinations. Allow retries for typos, but limit brute-force attempts. 20 attempts = ~3 codes worth of retries (6–7 tries per code).

- ✅ **Session Duration**
  - Default: 1 week (604800 seconds)
  - Optional: Extend to 30 days for better UX (fewer re-logins)
  - Reasoning: Trade-off between UX (longer session) and security (shorter session). For a finance app, 1–2 weeks is reasonable.

**Note:** Exact setting names vary by Supabase version. Check your dashboard under Authentication → Settings → Security or Rate Limits.

---

### Authentication → Email Templates

**Purpose:** Customize OTP email branding and content.

**Recommended Template:**

**Subject Line:**

```
Your ForecastAI code: {{ .Token }}
```

**Reasoning:**
- Includes code in subject line for quick access (user doesn't need to open email if they see notification)
- Branding ("ForecastAI") reinforces app identity
- Clear, concise

**Email Body (Plain Text):**

```
Your ForecastAI verification code is:

{{ .Token }}

This code expires in 10 minutes.

If you didn't request this code, you can safely ignore this email.

— The ForecastAI Team
```

**Email Body (HTML - Optional):**

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
    .code { font-size: 32px; font-weight: bold; letter-spacing: 4px; color: #007AFF; }
  </style>
</head>
<body>
  <p>Your ForecastAI verification code is:</p>
  <p class="code">{{ .Token }}</p>
  <p style="color: #666;">This code expires in 10 minutes.</p>
  <p style="color: #999; font-size: 12px;">
    If you didn't request this code, you can safely ignore this email.
  </p>
  <p>— The ForecastAI Team</p>
</body>
</html>
```

**Branding Notes:**

- **From Name:** "ForecastAI" (or "ForecastAI Team")
- **From Email:** `noreply@forecastai.app` (use your domain, not a generic Gmail)
- **Tone:** Professional but friendly; clear and concise
- **No Marketing:** Keep OTP emails purely transactional (no upsells, no links to blog posts)

**Key Principles:**

- ❌ **Do NOT include links** as the primary call-to-action (OTP is typed, not clicked)
- ✅ **Include expiry time** (manages expectations, reduces support questions)
- ✅ **Keep it short** (easier to scan on mobile)
- ✅ **Plain text fallback** (some email clients strip HTML)

---

### Production Launch: Additional Settings

**Before going live, also configure:**

- ✅ **Custom SMTP Provider**
  - Default: Supabase's SMTP (limited to 3–4 emails/hour on free tier)
  - Recommended for production: SendGrid, Postmark, AWS SES, Resend
  - Reasoning: Higher deliverability, no rate limits, custom domain (not `supabase.co`)

- ✅ **Custom Domain for Emails**
  - Use `noreply@forecastai.app` instead of `noreply@supabase.co`
  - Requires: DNS records (SPF, DKIM, DMARC)
  - Reasoning: Professional, higher deliverability, builds brand trust

- ✅ **Monitoring & Alerts**
  - Set up alerts for:
    - High OTP request rate (potential abuse)
    - Email delivery failures (SMTP issues)
    - Failed verification attempts (brute-force)
  - Tools: Supabase dashboard, Sentry, custom logging

- ✅ **Legal Compliance**
  - Terms of Service link in email footer (optional but recommended)
  - Privacy Policy link
  - CAN-SPAM compliance (if US users): Physical address in footer, unsubscribe option (for marketing emails only; OTP emails are transactional, exempt)

---

## C) iOS Integration Contract (Future — No Code Here)

**Note:** This section documents the expected contract between iOS and Supabase. No Swift code changes in this PR.

### Required Environment Variables (for iOS)

**iOS app must have access to these values (via `Info.plist`, build config, or environment):**

```swift
let supabaseURL = "https://your-project.supabase.co"
let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." // Public anon key
```

**Source:**
- Get these from Supabase Dashboard → Settings → API
- `supabaseURL`: Your project URL (unique per project)
- `supabaseAnonKey`: Public anon key (safe to embed in app)

**Security Note:**
- ✅ Safe to embed: `supabaseAnonKey` (public, designed for client use)
- ❌ NEVER embed: `service_role` key (server-only, full admin access)

---

### Auth Flow Calls (Expected iOS Implementation)

**1. Sign In with OTP (Screen 1 → Screen 2)**

```swift
// iOS calls this when user taps "Send code"
let response = try await supabase.auth.signInWithOTP(
    email: email,
    options: OTPOptions(
        emailRedirectTo: nil, // OTP doesn't use redirect
        shouldCreateUser: true // Auto-create user if not exists
    )
)

// On success: navigate to Screen 2 (code entry)
// On error: show inline error message
```

**2. Verify OTP (Screen 2 → App)**

```swift
// iOS calls this when user enters 6-digit code
let session = try await supabase.auth.verifyOTP(
    email: email,
    token: token, // 6-digit code from user input
    type: .email
)

// On success:
// - session.accessToken is valid JWT
// - session.user contains user ID, email, metadata
// - Store session securely (see below)
// - Navigate to AppShell

// On error: show inline error, allow retry
```

**3. Store Session Securely**

**Recommended: Use iOS Keychain (or Supabase SDK's built-in session storage)**

```swift
// Supabase Swift SDK handles session storage automatically
// Just initialize the client with session storage enabled:

let supabase = SupabaseClient(
    supabaseURL: URL(string: supabaseURL)!,
    supabaseKey: supabaseAnonKey,
    options: SupabaseClientOptions(
        auth: AuthOptions(
            storage: KeychainAuthStorage() // Or use default (UserDefaults)
        )
    )
)

// SDK automatically:
// - Stores access token & refresh token
// - Attaches tokens to API requests
// - Refreshes tokens when expired
```

**Manual Session Management (if needed):**

```swift
// Store tokens in Keychain
KeychainWrapper.standard.set(session.accessToken, forKey: "supabase.access_token")
KeychainWrapper.standard.set(session.refreshToken, forKey: "supabase.refresh_token")

// Retrieve on app launch
if let accessToken = KeychainWrapper.standard.string(forKey: "supabase.access_token") {
    // Restore session
    try await supabase.auth.setSession(accessToken: accessToken, refreshToken: refreshToken)
}
```

---

### 4. Attach Access Token to Database Requests (Automatic)

**Supabase SDK automatically attaches the access token to all database requests.**

```swift
// Example: Fetch user's forecasts
let forecasts: [Forecast] = try await supabase
    .from("forecasts")
    .select()
    .execute()
    .value

// SDK automatically:
// - Adds `Authorization: Bearer <access_token>` header
// - RLS policies on server enforce `auth.uid() = user_id`
// - User only sees their own data
```

**No manual header management needed!**

---

### 5. Sign Out

```swift
try await supabase.auth.signOut()

// SDK automatically:
// - Clears session from storage
// - Invalidates access token
// - Clears cookies (if any)

// iOS should:
// - Navigate back to auth screen (Screen 1)
// - Clear any locally cached user data
```

---

### DB Access Model (Enforced by Supabase RLS)

**All user data uses Row-Level Security (RLS) based on `auth.uid()`.**

**Example: `forecasts` table**

```sql
-- RLS Policy: Users can only read their own forecasts
CREATE POLICY "Users can read own forecasts"
ON forecasts
FOR SELECT
USING (auth.uid() = user_id);

-- RLS Policy: Users can only insert their own forecasts
CREATE POLICY "Users can insert own forecasts"
ON forecasts
FOR INSERT
WITH CHECK (auth.uid() = user_id);
```

**Key Points:**

- ✅ iOS uses `supabaseAnonKey` (public key) for all requests
- ✅ Supabase validates JWT (access token) to identify user
- ✅ RLS policies enforce per-user isolation (server-side, unhackable)
- ❌ NEVER use `service_role` key on device (bypasses RLS, full admin access)

**Why This Works:**

- Access token contains `user_id` in JWT payload
- Supabase automatically validates JWT on every request
- `auth.uid()` function extracts `user_id` from validated JWT
- RLS policies compare `auth.uid()` to `user_id` column in table
- Users cannot read/write other users' data (even if they try to hack the client)

---

## D) Database Implications (Already Done)

**Note:** This section assumes database tables are already configured with RLS. If not, add these policies.

### Tables

**`forecasts` table:**

```sql
CREATE TABLE forecasts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    ticker TEXT NOT NULL,
    forecast_data JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE forecasts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own forecasts"
ON forecasts FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own forecasts"
ON forecasts FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own forecasts"
ON forecasts FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own forecasts"
ON forecasts FOR DELETE
USING (auth.uid() = user_id);
```

**`watchlist` table:**

```sql
CREATE TABLE watchlist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    ticker TEXT NOT NULL,
    added_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, ticker) -- Prevent duplicate watchlist entries
);

-- RLS Policies
ALTER TABLE watchlist ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own watchlist"
ON watchlist FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own watchlist"
ON watchlist FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own watchlist"
ON watchlist FOR DELETE
USING (auth.uid() = user_id);
```

### Key Points

- ✅ `user_id` column references `auth.users(id)` (foreign key)
- ✅ `ON DELETE CASCADE`: If user is deleted, all their data is deleted
- ✅ RLS policies enforce per-user isolation on all CRUD operations
- ✅ No `UPDATE` policy on watchlist (immutable after creation; delete + re-add if needed)

---

## E) QA / Debug Playbook

### Local Testing with Supabase Studio

**1. Start Local Supabase**

```bash
cd /path/to/your/project
supabase start
```

**Output will include:**

```
API URL: http://localhost:54321
Studio URL: http://localhost:54323
Anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**2. Create a Test User in Studio**

- Open Studio: `http://localhost:54323`
- Navigate to: Authentication → Users
- Click: "Add user" (manual)
- Enter email: `test@example.com`
- Leave password blank (OTP is passwordless)
- Click: "Create user"

**3. Test OTP Flow Manually**

**Option A: Use Studio to simulate email (no actual email sent)**

- Studio → Authentication → Users → [your test user] → "Send password reset"
- Copy the OTP code from the logs (or check your email if SMTP is configured)

**Option B: Use Supabase CLI to send OTP**

```bash
# Send OTP to test@example.com
supabase auth send-otp --email test@example.com

# Check logs for OTP code (local mode prints codes to console)
```

**4. Verify OTP in iOS App**

- Run iOS app in simulator
- Enter `test@example.com` on Screen 1
- Tap "Send code"
- Check Supabase logs for OTP code (printed to console in local mode)
- Enter code in iOS app on Screen 2
- Should navigate to AppShell (success!)

---

### Common Issues

#### Issue: Codes Not Arriving (Email Deliverability)

**Symptoms:**
- User taps "Send code" but no email arrives
- No error shown in app

**Possible Causes:**

1. **Spam Folder**
   - Solution: Check spam/junk folder
   - Long-term fix: Configure custom SMTP provider + SPF/DKIM

2. **Wrong Email Domain**
   - Symptom: Emails to Gmail work, but corporate emails (e.g., @company.com) fail
   - Solution: Corporate email servers may block emails from unknown domains
   - Fix: Use custom SMTP provider with verified domain

3. **Email Template Issues**
   - Symptom: Emails sent but body is blank or malformed
   - Solution: Check email template in Supabase Dashboard → Authentication → Email Templates
   - Fix: Ensure `{{ .Token }}` variable is present in template

4. **SMTP Rate Limits**
   - Symptom: First email works, but subsequent emails fail
   - Cause: Supabase free tier SMTP limited to 3–4 emails/hour
   - Solution: Use custom SMTP provider (SendGrid, Postmark, AWS SES)

5. **Local Development (No Real Emails)**
   - Symptom: Running `supabase start` locally; no emails sent
   - Cause: Local Supabase doesn't send real emails (logs codes to console instead)
   - Solution: Check terminal output for OTP code:
     ```
     OTP code for test@example.com: 123456
     ```

---

#### Issue: OTP Expired

**Symptoms:**
- User enters code but gets error: "Code expired"

**Causes:**
- More than 10 minutes elapsed since code was sent
- User waited too long to check email

**Solution:**
- Tap "Resend code" to get a new code
- Check that OTP expiry is set to 10 minutes (see Section B)

**Prevention:**
- Show timer on Screen 2 (e.g., "Code expires in 8:32")
- Encourage users to check email immediately after requesting code

---

#### Issue: Wrong Environment (Prod vs Local Keys)

**Symptoms:**
- App works in local dev, but fails in TestFlight/production
- Error: "Invalid API key" or "Network error"

**Cause:**
- iOS app is using local Supabase URL/keys instead of production keys

**Solution:**

**Use build configurations in Xcode:**

```swift
#if DEBUG
let supabaseURL = "http://localhost:54321" // Local
let supabaseAnonKey = "eyJ..." // Local anon key
#else
let supabaseURL = "https://your-project.supabase.co" // Production
let supabaseAnonKey = "eyJ..." // Production anon key
#endif
```

**OR use environment variables / build schemes:**

- Debug scheme → Local keys
- Release scheme → Production keys

---

#### Issue: Invalid Code (User Typo)

**Symptoms:**
- User enters code but gets error: "Invalid code"

**Causes:**
- Typo (e.g., `O` vs `0`, `I` vs `1`)
- Code already used (codes are single-use)
- Wrong email (user requested code for email A, but is trying to verify email B)

**Solution:**
- Allow user to retry (clear inputs, let them re-enter)
- After 3 failed attempts, suggest "Resend code"
- Use clear font on Screen 2 (distinguish `0` from `O`, `1` from `I`)

---

#### Issue: Too Many Attempts (Rate Limited)

**Symptoms:**
- User taps "Send code" but gets error: "Too many attempts"

**Cause:**
- Exceeded rate limit (e.g., 5 requests/hour per IP)

**Solution:**
- Show error message: "Too many attempts. Please try again in [X] minutes."
- Calculate retry time from response headers (if Supabase provides it)
- Prevention: Set conservative rate limits (see Section B)

**For Testing (Local):**
- Temporarily disable rate limits in Supabase Studio (local only!)
- OR wait for rate limit window to reset
- OR use different IP (e.g., switch from Wi-Fi to mobile hotspot)

---

### Debug Checklist

**Before filing a bug, check:**

- ✅ Supabase project is running (`supabase start` for local, or check production dashboard)
- ✅ Email provider is enabled in Dashboard → Authentication → Providers → Email
- ✅ OTP is enabled (not disabled)
- ✅ iOS app is using correct `supabaseURL` and `supabaseAnonKey` (check build config)
- ✅ Network connectivity (iOS has internet access)
- ✅ Check Supabase logs for errors (Dashboard → Logs → Auth Logs)
- ✅ Check iOS console logs for SDK errors

---

### Testing Checklist (Before Production)

**Auth Flow:**

- ✅ User can request OTP on Screen 1
- ✅ Email arrives within 30 seconds
- ✅ Email contains 6-digit code
- ✅ User can enter code on Screen 2
- ✅ Valid code navigates to AppShell
- ✅ Invalid code shows error (allows retry)
- ✅ Expired code shows error (suggests resend)
- ✅ User can tap "Resend code" after 60 seconds
- ✅ User can tap "Try a different email" to go back
- ✅ Session persists on app restart (user stays logged in)

**Edge Cases:**

- ✅ User enters code with leading/trailing spaces (should trim)
- ✅ User enters code in lowercase (should work; OTP is case-insensitive)
- ✅ User requests multiple codes in quick succession (rate limit enforced)
- ✅ User tries to verify code for wrong email (should fail)
- ✅ User closes app mid-flow and reopens (should resume on Screen 2 if code still valid)

**Database Access:**

- ✅ User A cannot read User B's forecasts
- ✅ User A cannot update/delete User B's data
- ✅ Unauthenticated requests return 401 (if RLS enforced)
- ✅ Invalid JWT returns 401 (if user tampers with token)

**Production Readiness:**

- ✅ Custom SMTP provider configured (SendGrid/Postmark/etc.)
- ✅ Email deliverability tested with real domains (Gmail, Outlook, corporate)
- ✅ Rate limits configured (5–10 requests/hour)
- ✅ Email template branding matches app (logo, colors, tone)
- ✅ Legal compliance (Terms, Privacy links in email footer)

---

## Summary

**This spec provides:**

1. ✅ **Product UX:** Screen-by-screen design for OTP auth (Robinhood-like simplicity)
2. ✅ **Supabase Settings:** Copy-ready checklist for dashboard configuration
3. ✅ **iOS Contract:** Expected API calls (no code, just documentation)
4. ✅ **Database Model:** RLS policies for secure per-user isolation
5. ✅ **QA Playbook:** Testing steps, common issues, and debug guidance

**Next Steps (Not in this PR):**

- Implement iOS screens (Screen 1 & Screen 2)
- Integrate Supabase Swift SDK
- Test auth flow end-to-end
- Configure production SMTP provider
- Launch! 🚀
