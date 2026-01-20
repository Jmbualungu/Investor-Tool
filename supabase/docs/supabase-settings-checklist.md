# Supabase Settings Checklist

**Quick reference for configuring Supabase for ForecastAI iOS app.**

---

## ✅ Auth (OTP)

**Dashboard → Authentication → Providers → Email**

- [ ] Enable Email Provider
- [ ] Enable Email OTP (passwordless)
- [ ] OTP Length: 6 digits
- [ ] OTP Expiry: 10 minutes (600 seconds)
- [ ] Email Confirmations: OFF (OTP already proves inbox access)
- [ ] Site URL: Set to production domain (e.g., `https://forecastai.app`)
  - Local dev: `http://localhost:3000`
- [ ] Redirect URLs: Add production domain (e.g., `https://forecastai.app/*`)
  - Optional: `http://localhost:*` for local testing

---

## ✅ Email Templates

**Dashboard → Authentication → Email Templates → Magic Link (or OTP)**

**Subject:**

```
Your ForecastAI code: {{ .Token }}
```

**Body (Plain Text):**

```
Your ForecastAI verification code is:

{{ .Token }}

This code expires in 10 minutes.

If you didn't request this code, you can safely ignore this email.

— The ForecastAI Team
```

**Branding:**

- [ ] From Name: "ForecastAI" or "ForecastAI Team"
- [ ] From Email: `noreply@forecastai.app` (use custom domain)
- [ ] Tone: Professional, concise, no marketing

---

## ✅ Rate Limiting

**Dashboard → Authentication → Settings → Security / Rate Limits**

- [ ] OTP Requests per Hour (per IP): 5–10
- [ ] Verify Attempts per Hour (per IP): 20
- [ ] Session Duration: 1 week (604800 sec) or 30 days (for better UX)

**Purpose:** Prevent abuse, brute-force, and spam.

---

## ✅ RLS Verification

**Dashboard → SQL Editor (or Table Editor → Policies)**

**Tables to check:**

- [ ] `forecasts` table:
  - RLS enabled
  - Policies enforce `auth.uid() = user_id` for SELECT, INSERT, UPDATE, DELETE
- [ ] `watchlist` table:
  - RLS enabled
  - Policies enforce `auth.uid() = user_id` for SELECT, INSERT, DELETE

**Verify:**

```sql
-- Check RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('forecasts', 'watchlist');

-- Should return rowsecurity = true for both
```

**Test:**

- [ ] User A cannot read User B's data
- [ ] Unauthenticated requests return 401

---

## ✅ API Keys (for iOS)

**Dashboard → Settings → API**

**Required for iOS app:**

- [ ] `supabaseURL`: Copy "Project URL" (e.g., `https://xyz.supabase.co`)
- [ ] `supabaseAnonKey`: Copy "anon public" key (safe to embed in app)

**NEVER use in iOS app:**

- ❌ `service_role` key (server-only; bypasses RLS)

**Store in iOS:**

- Option A: Build configuration (Debug vs Release)
- Option B: Environment variables
- Option C: `Info.plist` (with `.gitignore` for secrets)

---

## ✅ Edge Functions (Optional)

**Dashboard → Edge Functions**

**Functions to deploy:**

- [ ] `auth-ping` (JWT validation for debugging)
  - Deploy: `supabase functions deploy auth-ping`
  - Test: `curl https://xyz.supabase.co/functions/v1/auth-ping -H "Authorization: Bearer <token>"`

**Purpose:** Validate iOS is sending correct JWT tokens.

---

## ✅ Production Launch

**Before going live:**

### SMTP Provider (Email Deliverability)

- [ ] Configure custom SMTP provider:
  - Options: SendGrid, Postmark, AWS SES, Resend
  - Dashboard → Settings → Auth → SMTP Settings
- [ ] Verify custom domain:
  - DNS records: SPF, DKIM, DMARC
  - Test with Gmail, Outlook, corporate domains
- [ ] Test email deliverability:
  - Send OTP to multiple email providers
  - Check spam folder, delivery time (<30 seconds ideal)

### Domain & URLs

- [ ] Update Site URL to production domain
- [ ] Update Redirect URLs to production domain
- [ ] Remove localhost from allowed redirect URLs (or keep for staging)

### Monitoring & Alerts

- [ ] Set up monitoring:
  - Supabase Dashboard → Logs → Auth Logs
  - Alert on high OTP request rate (potential abuse)
  - Alert on email delivery failures (SMTP issues)
- [ ] Optional: Integrate Sentry or custom logging for iOS errors

### Security

- [ ] Review rate limits (ensure they're enforced in production)
- [ ] Review RLS policies (test with multiple users)
- [ ] Rotate `service_role` key if ever exposed (unlikely, but good practice)
- [ ] Enable 2FA for Supabase dashboard access (team accounts)

### Legal & Compliance

- [ ] Add Terms of Service link to email footer (optional but recommended)
- [ ] Add Privacy Policy link
- [ ] CAN-SPAM compliance (if US users):
  - Physical address in footer (transactional emails exempt, but good practice)
  - Unsubscribe option (for marketing emails only; OTP emails are transactional)

### iOS App

- [ ] Use production `supabaseURL` and `supabaseAnonKey` in Release build
- [ ] Remove or restrict ATS exceptions in `Info.plist` (allow HTTPS only)
- [ ] Test auth flow in TestFlight before App Store submission
- [ ] Test session persistence on app restart

---

## ✅ Post-Launch Monitoring

**Weekly Checks:**

- [ ] Review auth success/failure rates (Dashboard → Analytics)
- [ ] Check email delivery rates (SMTP provider dashboard)
- [ ] Monitor rate limit triggers (Logs → Auth)
- [ ] Review user growth (Dashboard → Authentication → Users)

**Monthly Checks:**

- [ ] Rotate SMTP credentials (good practice)
- [ ] Review RLS policies (if schema changes)
- [ ] Check for Supabase updates (CLI, SDK, dashboard features)

---

## Quick Links

**Docs:**

- [OTP Auth UX Spec](./auth-otp-spec.md)
- [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
- [Row-Level Security Docs](https://supabase.com/docs/guides/auth/row-level-security)

**Dashboards:**

- Supabase Dashboard: `https://app.supabase.com/project/<your-project-id>`
- Local Studio: `http://localhost:54323` (when running `supabase start`)

**CLI Commands:**

```bash
# Start local Supabase
supabase start

# Deploy edge functions
supabase functions deploy auth-ping

# Push migrations to production
supabase db push

# View auth logs (local)
supabase logs auth
```

---

**Status:** Ready for iOS implementation once these settings are configured.
