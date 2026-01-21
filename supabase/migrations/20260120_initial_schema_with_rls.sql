--
-- Initial Schema for Investor Tool
-- Run this in Supabase SQL Editor
--
-- Creates:
-- - profiles table (user metadata)
-- - watchlists table (user's tracked tickers)
-- - forecasts table (user's valuation models)
-- - forecast_versions table (versioned assumptions/results)
-- - rate_limits table (for Edge Function rate limiting)
--
-- All tables have RLS enabled with strict user ownership policies
--

-- ============================================================================
-- PROFILES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    display_name TEXT
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policies: Users can only access their own profile
CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (id = auth.uid());

CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT
    WITH CHECK (id = auth.uid());

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- Create profile automatically on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- WATCHLISTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS watchlists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    ticker TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, ticker)
);

-- Index for fast user lookups
CREATE INDEX IF NOT EXISTS idx_watchlists_user_id ON watchlists(user_id);
CREATE INDEX IF NOT EXISTS idx_watchlists_ticker ON watchlists(ticker);

-- Enable RLS
ALTER TABLE watchlists ENABLE ROW LEVEL SECURITY;

-- Policies: Users can only access their own watchlist items
CREATE POLICY "Users can view own watchlist"
    ON watchlists FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "Users can insert own watchlist"
    ON watchlists FOR INSERT
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own watchlist"
    ON watchlists FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own watchlist"
    ON watchlists FOR DELETE
    USING (user_id = auth.uid());

-- ============================================================================
-- FORECASTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS forecasts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    ticker TEXT NOT NULL,
    name TEXT,
    base_currency TEXT DEFAULT 'USD',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_forecasts_user_id ON forecasts(user_id);
CREATE INDEX IF NOT EXISTS idx_forecasts_user_ticker ON forecasts(user_id, ticker);
CREATE INDEX IF NOT EXISTS idx_forecasts_updated_at ON forecasts(updated_at DESC);

-- Enable RLS
ALTER TABLE forecasts ENABLE ROW LEVEL SECURITY;

-- Policies: Users can only access their own forecasts
CREATE POLICY "Users can view own forecasts"
    ON forecasts FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "Users can insert own forecasts"
    ON forecasts FOR INSERT
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own forecasts"
    ON forecasts FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own forecasts"
    ON forecasts FOR DELETE
    USING (user_id = auth.uid());

-- Trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_forecasts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_forecasts_updated_at ON forecasts;
CREATE TRIGGER trigger_update_forecasts_updated_at
    BEFORE UPDATE ON forecasts
    FOR EACH ROW
    EXECUTE FUNCTION update_forecasts_updated_at();

-- ============================================================================
-- FORECAST_VERSIONS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS forecast_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    forecast_id UUID NOT NULL REFERENCES forecasts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    assumptions JSONB NOT NULL,
    results JSONB,
    note TEXT
);

-- Indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_forecast_versions_forecast_id ON forecast_versions(forecast_id);
CREATE INDEX IF NOT EXISTS idx_forecast_versions_user_id ON forecast_versions(user_id);
CREATE INDEX IF NOT EXISTS idx_forecast_versions_created_at ON forecast_versions(forecast_id, created_at DESC);

-- Enable RLS
ALTER TABLE forecast_versions ENABLE ROW LEVEL SECURITY;

-- Policies: Users can only access their own forecast versions
-- AND versions must belong to forecasts they own
CREATE POLICY "Users can view own forecast versions"
    ON forecast_versions FOR SELECT
    USING (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM forecasts
            WHERE forecasts.id = forecast_versions.forecast_id
            AND forecasts.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own forecast versions"
    ON forecast_versions FOR INSERT
    WITH CHECK (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM forecasts
            WHERE forecasts.id = forecast_versions.forecast_id
            AND forecasts.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own forecast versions"
    ON forecast_versions FOR UPDATE
    USING (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM forecasts
            WHERE forecasts.id = forecast_versions.forecast_id
            AND forecasts.user_id = auth.uid()
        )
    )
    WITH CHECK (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM forecasts
            WHERE forecasts.id = forecast_versions.forecast_id
            AND forecasts.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete own forecast versions"
    ON forecast_versions FOR DELETE
    USING (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM forecasts
            WHERE forecasts.id = forecast_versions.forecast_id
            AND forecasts.user_id = auth.uid()
        )
    );

-- ============================================================================
-- RATE_LIMITS TABLE (for Edge Functions)
-- ============================================================================

CREATE TABLE IF NOT EXISTS rate_limits (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    key TEXT NOT NULL,
    window_start TIMESTAMPTZ NOT NULL,
    count INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id, key, window_start)
);

-- Index for fast lookups and cleanup
CREATE INDEX IF NOT EXISTS idx_rate_limits_window ON rate_limits(window_start);

-- Enable RLS (users can't directly access this table - only via Edge Functions)
ALTER TABLE rate_limits ENABLE ROW LEVEL SECURITY;

-- No public policies - only service role can access
-- Edge Functions run with service role permissions

-- ============================================================================
-- UTILITY: Increment rate limit counter (atomic upsert)
-- ============================================================================

CREATE OR REPLACE FUNCTION increment_rate_limit(
    p_user_id UUID,
    p_key TEXT,
    p_window_start TIMESTAMPTZ
)
RETURNS void AS $$
BEGIN
    INSERT INTO rate_limits (user_id, key, window_start, count)
    VALUES (p_user_id, p_key, p_window_start, 1)
    ON CONFLICT (user_id, key, window_start)
    DO UPDATE SET count = rate_limits.count + 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- UTILITY: Clean up old rate limit windows (run periodically)
-- ============================================================================

CREATE OR REPLACE FUNCTION cleanup_old_rate_limits()
RETURNS void AS $$
BEGIN
    DELETE FROM rate_limits
    WHERE window_start < NOW() - INTERVAL '1 hour';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Uncomment to verify RLS is enabled on all tables:
/*
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('profiles', 'watchlists', 'forecasts', 'forecast_versions', 'rate_limits');
*/

-- Uncomment to list all RLS policies:
/*
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
*/

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Schema created successfully!';
    RAISE NOTICE '✅ RLS enabled on all user tables';
    RAISE NOTICE '✅ Policies configured for strict user ownership';
    RAISE NOTICE '';
    RAISE NOTICE '📋 Next steps:';
    RAISE NOTICE '1. Test auth signup/signin from iOS app';
    RAISE NOTICE '2. Run smoke tests in Backend Status screen';
    RAISE NOTICE '3. Deploy Edge Function: supabase functions deploy write-forecast-version';
    RAISE NOTICE '4. Configure rate limiting in Supabase Dashboard';
END $$;
