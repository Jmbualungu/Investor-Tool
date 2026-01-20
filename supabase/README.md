# ForecastAI Supabase Backend

**Backend infrastructure for ForecastAI iOS app using Supabase.**

This directory contains:
- Database migrations (schema, RLS policies)
- Edge Functions (serverless API endpoints)
- Documentation (auth UX, configuration)

---

## 📁 Directory Structure

```
supabase/
├── docs/                               # Documentation
│   ├── auth-otp-spec.md                # OTP auth UX specification
│   └── supabase-settings-checklist.md  # Configuration checklist
├── functions/                          # Edge Functions (Deno)
│   └── auth-ping/                      # JWT validation endpoint
│       └── index.ts
├── migrations/                         # Database schema & RLS policies
│   └── (SQL migration files)
└── README.md                           # This file
```

---

## 🔐 Auth (OTP-First)

**Primary authentication method:** Email + OTP (One-Time Password)

**User flow:**
1. User enters email → receives 6-digit code
2. User enters code → authenticated
3. Session stored securely (Keychain on iOS)

**Documentation:**

- **[OTP Auth UX Spec](./docs/auth-otp-spec.md)** — Complete product spec (screens, settings, iOS integration contract)
- **[Supabase Settings Checklist](./docs/supabase-settings-checklist.md)** — Quick reference for dashboard configuration

**Key features:**

- ✅ Passwordless (no passwords to remember or leak)
- ✅ Robinhood-like UX (simple, fast, mobile-first)
- ✅ Row-Level Security (RLS) enforces per-user data isolation
- ✅ JWT-based sessions (access token + refresh token)
- ✅ Rate limiting (prevents abuse and brute-force)

---

## 🚀 Quick Start (Local Development)

### Prerequisites

- **Supabase CLI** (install if not already):

  ```bash
  # macOS
  brew install supabase/tap/supabase

  # Or use npm
  npm install -g supabase
  ```

- **Docker Desktop** (required by Supabase CLI)

### 1. Start Supabase Locally

```bash
cd /path/to/your/project
supabase start
```

**Output:**

```
Started supabase local development setup.

         API URL: http://localhost:54321
          DB URL: postgresql://postgres:postgres@localhost:54322/postgres
      Studio URL: http://localhost:54323
    Inbucket URL: http://localhost:54324
      JWT secret: super-secret-jwt-token-with-at-least-32-characters-long
        anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Important:**
- **API URL** (`http://localhost:54321`): Use this in iOS app for local testing
- **Studio URL** (`http://localhost:54323`): Web UI for managing database, users, etc.
- **Inbucket URL** (`http://localhost:54324`): Local email inbox (OTP codes sent here)
- **anon key**: Safe to embed in iOS app (public key)
- **service_role key**: NEVER use in iOS app (server-only, bypasses RLS)

### 2. Open Supabase Studio

Visit `http://localhost:54323` in your browser.

**Available sections:**
- **Table Editor**: View/edit database tables
- **SQL Editor**: Run SQL queries
- **Authentication**: Manage users, view auth logs
- **Storage**: File uploads (if needed later)
- **Functions**: Deploy and test Edge Functions

### 3. Create a Test User

**Option A: Via Studio UI**

1. Studio → Authentication → Users
2. Click "Add user"
3. Enter email: `test@example.com`
4. Leave password blank (OTP is passwordless)
5. Click "Create user"

**Option B: Via SQL Editor**

```sql
-- Create a test user
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'test@example.com',
  crypt('password', gen_salt('bf')), -- Dummy password (won't be used for OTP)
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{}',
  NOW(),
  NOW()
);
```

### 4. Test OTP Flow

**Send OTP:**

- In local mode, OTP codes are printed to console (no real emails sent)
- Check terminal where `supabase start` is running
- OR check Inbucket: `http://localhost:54324` (local email inbox)

**Example console output:**

```
OTP code for test@example.com: 123456
```

**Verify OTP in iOS app:**

1. Run iOS app in simulator
2. Enter `test@example.com` on auth screen
3. Tap "Send code"
4. Check console for OTP code
5. Enter code in iOS app
6. Should navigate to app (success!)

---

## 🛠️ Edge Functions

### Available Functions

#### `auth-ping` — JWT Validation (Debugging)

**Purpose:** Validate that iOS app is sending correct JWT tokens.

**Endpoint:** `GET /functions/v1/auth-ping`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200 OK):**

```json
{
  "ok": true,
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "metadata": {
    "emailVerified": true,
    "lastSignIn": "2026-01-20T12:00:00.000Z",
    "createdAt": "2026-01-15T10:30:00.000Z"
  },
  "message": "Token is valid"
}
```

**Response (401 Unauthorized):**

```json
{
  "ok": false,
  "error": "Invalid or expired token",
  "code": "INVALID_TOKEN"
}
```

---

### Serving Functions Locally

```bash
# Start functions (in separate terminal)
supabase functions serve
```

**Output:**

```
Serving functions on http://localhost:54321/functions/v1/
- auth-ping
```

**Test with curl:**

```bash
# Get access token from iOS app (or use Supabase Studio to generate one)
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# Test auth-ping
curl http://localhost:54321/functions/v1/auth-ping \
  -H "Authorization: Bearer $TOKEN"
```

**Expected output:**

```json
{
  "ok": true,
  "userId": "...",
  "email": "test@example.com",
  "message": "Token is valid"
}
```

---

### Deploying Functions (Production)

**Prerequisites:**

- Link project to Supabase Cloud:

  ```bash
  supabase link --project-ref <your-project-id>
  ```

**Deploy function:**

```bash
supabase functions deploy auth-ping
```

**Output:**

```
Deploying function auth-ping to Supabase project...
✓ Function deployed: https://xyz.supabase.co/functions/v1/auth-ping
```

**Test production function:**

```bash
curl https://xyz.supabase.co/functions/v1/auth-ping \
  -H "Authorization: Bearer $TOKEN"
```

---

## 📝 Database Migrations

### Directory: `supabase/migrations/`

**Migrations are versioned SQL files that define database schema and RLS policies.**

**Example migration:** `20260120000000_initial_schema.sql`

```sql
-- Create forecasts table
CREATE TABLE forecasts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    ticker TEXT NOT NULL,
    forecast_data JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE forecasts ENABLE ROW LEVEL SECURITY;

-- RLS Policies
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

### Creating Migrations

```bash
# Create a new migration
supabase migration new <migration_name>

# Example
supabase migration new add_watchlist_table
```

This creates: `supabase/migrations/<timestamp>_add_watchlist_table.sql`

### Applying Migrations

**Local:**

```bash
# Migrations are auto-applied when you run `supabase start`
# Or manually apply:
supabase db reset
```

**Production:**

```bash
# Push migrations to production
supabase db push
```

---

## 🔐 Security Notes

### API Keys

- ✅ **anon key**: Safe to embed in iOS app (public key)
- ❌ **service_role key**: NEVER use in iOS app (server-only, bypasses RLS)

### Row-Level Security (RLS)

**All user data tables MUST have RLS enabled.**

**Example:**

```sql
-- Enable RLS on table
ALTER TABLE forecasts ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read their own data
CREATE POLICY "Users can read own forecasts"
ON forecasts FOR SELECT
USING (auth.uid() = user_id);
```

**Why RLS?**

- Enforced at database level (cannot be bypassed by client)
- `auth.uid()` extracts user ID from JWT (validated by Supabase)
- Users cannot access other users' data (even if they hack the client)

### Testing RLS

```sql
-- Test as authenticated user
SET request.jwt.claims.sub = '550e8400-e29b-41d4-a716-446655440000';

-- Should only return rows where user_id matches JWT sub
SELECT * FROM forecasts;
```

---

## 📚 Configuration Checklist

**Before deploying to production, ensure:**

- ✅ Auth provider enabled (Email OTP)
- ✅ Email templates customized
- ✅ Rate limits configured (5–10 OTP requests/hour)
- ✅ RLS policies enabled on all user tables
- ✅ Custom SMTP provider configured (SendGrid, Postmark, etc.)
- ✅ Production API keys stored securely (iOS build config)
- ✅ Edge functions deployed and tested

**Full checklist:** [Supabase Settings Checklist](./docs/supabase-settings-checklist.md)

---

## 🧪 Testing Workflow

### 1. Local Testing (Before iOS Integration)

**Start Supabase:**

```bash
supabase start
```

**Test auth flow in Studio:**

1. Studio → Authentication → Users → Add user
2. Enter test email
3. Check Inbucket (`http://localhost:54324`) for OTP code
4. Verify code manually in SQL Editor:

   ```sql
   -- Example: Verify OTP (replace with actual values)
   SELECT auth.verify_otp('test@example.com', '123456', 'email');
   ```

**Test RLS policies:**

```sql
-- Switch to authenticated user context
SET request.jwt.claims.sub = '<user_id>';

-- Test queries
SELECT * FROM forecasts; -- Should only return user's own data
INSERT INTO forecasts (user_id, ticker, forecast_data)
VALUES ('<user_id>', 'AAPL', '{}'); -- Should succeed

-- Try to access another user's data
SET request.jwt.claims.sub = '<different_user_id>';
SELECT * FROM forecasts; -- Should NOT return previous user's data
```

### 2. iOS Integration Testing

**Configure iOS app:**

```swift
// Use local Supabase
let supabaseURL = "http://localhost:54321"
let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." // From `supabase start` output
```

**Test auth flow:**

1. Run iOS app in simulator
2. Enter email → tap "Send code"
3. Check terminal for OTP code (printed to console in local mode)
4. Enter code in app
5. Verify session stored (app should stay logged in on restart)

**Test database access:**

1. Create a forecast in iOS app
2. Check Studio → Table Editor → forecasts
3. Should see new row with `user_id` matching authenticated user

### 3. Production Testing

**Before launch:**

- ✅ Test OTP flow with real emails (Gmail, Outlook, corporate domains)
- ✅ Verify email deliverability (check spam, delivery time)
- ✅ Test rate limits (try exceeding limits, verify errors shown)
- ✅ Test RLS with multiple users (User A cannot see User B's data)
- ✅ Test session persistence (app restart, token refresh)

---

## 🐛 Troubleshooting

### Issue: `supabase: command not found`

**Solution:**

```bash
# macOS
brew install supabase/tap/supabase

# Or npm
npm install -g supabase
```

### Issue: Docker errors when running `supabase start`

**Solution:**

- Ensure Docker Desktop is running
- Check Docker has enough resources (Settings → Resources → Memory: 4GB+)

### Issue: Migrations not applied

**Solution:**

```bash
# Reset database (WARNING: deletes all data)
supabase db reset
```

### Issue: Edge function not found

**Solution:**

```bash
# Ensure functions are being served
supabase functions serve

# Verify function exists
ls supabase/functions/
```

### Issue: JWT validation fails in `auth-ping`

**Possible causes:**

- Wrong token (expired, invalid, or from different project)
- iOS app using production keys but testing against local Supabase (or vice versa)
- Token not sent in `Authorization: Bearer` header

**Solution:**

```bash
# Test with curl (replace TOKEN with actual JWT)
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
curl http://localhost:54321/functions/v1/auth-ping \
  -H "Authorization: Bearer $TOKEN" \
  -v
```

---

## 📖 Further Reading

**Supabase Docs:**

- [Auth: Email OTP](https://supabase.com/docs/guides/auth/auth-email-otp)
- [Row-Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Edge Functions](https://supabase.com/docs/guides/functions)
- [Local Development](https://supabase.com/docs/guides/cli/local-development)

**Project Docs:**

- [OTP Auth UX Spec](./docs/auth-otp-spec.md) — Complete product spec
- [Supabase Settings Checklist](./docs/supabase-settings-checklist.md) — Configuration guide

---

## 🚢 Deployment

### Production Checklist

- [ ] Link project: `supabase link --project-ref <id>`
- [ ] Push migrations: `supabase db push`
- [ ] Deploy functions: `supabase functions deploy auth-ping`
- [ ] Configure SMTP provider (Dashboard → Settings → Auth)
- [ ] Update iOS app with production keys (`supabaseURL`, `supabaseAnonKey`)
- [ ] Test auth flow in TestFlight
- [ ] Monitor auth logs (Dashboard → Authentication → Logs)

**Post-deployment:**

- Monitor email deliverability (SMTP dashboard)
- Review auth success/failure rates (Supabase Analytics)
- Set up alerts for rate limit triggers (Dashboard → Logs)

---

## 🤝 Contributing

**When adding new features:**

1. Create migration for schema changes: `supabase migration new <name>`
2. Add RLS policies for new tables
3. Test locally: `supabase db reset` → verify in Studio
4. Deploy to production: `supabase db push`
5. Update docs (this README, or add new doc in `docs/`)

---

## 📄 License

MIT

---

**Questions?** Check logs, test endpoints with curl, and consult the [OTP Auth UX Spec](./docs/auth-otp-spec.md) for detailed guidance.
