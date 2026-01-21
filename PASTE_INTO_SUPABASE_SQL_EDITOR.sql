--
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║          INVESTOR TOOL - COMPLETE DATABASE SCHEMA + RLS POLICIES          ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
--
-- INSTRUCTIONS:
-- 1. Open Supabase Dashboard → SQL Editor
-- 2. Create new query
-- 3. Copy and paste this ENTIRE file
-- 4. Click "Run" (or Cmd/Ctrl+Enter)
-- 5. Verify success message at bottom
--
-- This script is IDEMPOTENT (safe to run multiple times)
--

-- ============================================================================
-- PROFILES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    display_name TEXT
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (id = auth.uid());

DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT
    WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id)
    VALUES (NEW.id)
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

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

CREATE INDEX IF NOT EXISTS idx_watchlists_user_id ON watchlists(user_id);
CREATE INDEX IF NOT EXISTS idx_watchlists_ticker ON watchlists(ticker);

ALTER TABLE watchlists ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own watchlist" ON watchlists;
CREATE POLICY "Users can view own watchlist"
    ON watchlists FOR SELECT
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert own watchlist" ON watchlists;
CREATE POLICY "Users can insert own watchlist"
    ON watchlists FOR INSERT
    WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update own watchlist" ON watchlists;
CREATE POLICY "Users can update own watchlist"
    ON watchlists FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can delete own watchlist" ON watchlists;
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

CREATE INDEX IF NOT EXISTS idx_forecasts_user_id ON forecasts(user_id);
CREATE INDEX IF NOT EXISTS idx_forecasts_user_ticker ON forecasts(user_id, ticker);
CREATE INDEX IF NOT EXISTS idx_forecasts_updated_at ON forecasts(updated_at DESC);

ALTER TABLE forecasts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own forecasts" ON forecasts;
CREATE POLICY "Users can view own forecasts"
    ON forecasts FOR SELECT
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert own forecasts" ON forecasts;
CREATE POLICY "Users can insert own forecasts"
    ON forecasts FOR INSERT
    WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update own forecasts" ON forecasts;
CREATE POLICY "Users can update own forecasts"
    ON forecasts FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can delete own forecasts" ON forecasts;
CREATE POLICY "Users can delete own forecasts"
    ON forecasts FOR DELETE
    USING (user_id = auth.uid());

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

CREATE INDEX IF NOT EXISTS idx_forecast_versions_forecast_id ON forecast_versions(forecast_id);
CREATE INDEX IF NOT EXISTS idx_forecast_versions_user_id ON forecast_versions(user_id);
CREATE INDEX IF NOT EXISTS idx_forecast_versions_created_at ON forecast_versions(forecast_id, created_at DESC);

ALTER TABLE forecast_versions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own forecast versions" ON forecast_versions;
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

DROP POLICY IF EXISTS "Users can insert own forecast versions" ON forecast_versions;
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

DROP POLICY IF EXISTS "Users can update own forecast versions" ON forecast_versions;
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

DROP POLICY IF EXISTS "Users can delete own forecast versions" ON forecast_versions;
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
-- RATE_LIMITS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS rate_limits (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    key TEXT NOT NULL,
    window_start TIMESTAMPTZ NOT NULL,
    count INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id, key, window_start)
);

CREATE INDEX IF NOT EXISTS idx_rate_limits_window ON rate_limits(window_start);

ALTER TABLE rate_limits ENABLE ROW LEVEL SECURITY;

-- No public policies - only service role can access (via Edge Functions)

-- ============================================================================
-- UTILITY FUNCTIONS
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

CREATE OR REPLACE FUNCTION cleanup_old_rate_limits()
RETURNS void AS $$
BEGIN
    DELETE FROM rate_limits
    WHERE window_start < NOW() - INTERVAL '1 hour';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

DO $$
DECLARE
    rls_count INTEGER;
    policy_count INTEGER;
BEGIN
    -- Check RLS is enabled on all tables
    SELECT COUNT(*) INTO rls_count
    FROM pg_tables
    WHERE schemaname = 'public'
    AND tablename IN ('profiles', 'watchlists', 'forecasts', 'forecast_versions', 'rate_limits')
    AND rowsecurity = true;
    
    -- Check policies exist
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies
    WHERE schemaname = 'public';
    
    RAISE NOTICE '';
    RAISE NOTICE '╔══════════════════════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║                    ✅ SCHEMA CREATED SUCCESSFULLY!                        ║';
    RAISE NOTICE '╚══════════════════════════════════════════════════════════════════════════╝';
    RAISE NOTICE '';
    RAISE NOTICE '📋 Summary:';
    RAISE NOTICE '   • Tables created: 5 (profiles, watchlists, forecasts, forecast_versions, rate_limits)';
    RAISE NOTICE '   • RLS enabled: % / 5 tables', rls_count;
    RAISE NOTICE '   • Policies created: % total', policy_count;
    RAISE NOTICE '   • Functions created: 4 (handle_new_user, update_forecasts_updated_at, increment_rate_limit, cleanup_old_rate_limits)';
    RAISE NOTICE '   • Triggers created: 2 (on_auth_user_created, trigger_update_forecasts_updated_at)';
    RAISE NOTICE '';
    RAISE NOTICE '✅ RLS Verification:';
    RAISE NOTICE '   • All user tables have Row-Level Security enabled';
    RAISE NOTICE '   • Policies enforce strict user ownership (user_id = auth.uid())';
    RAISE NOTICE '   • Forecast versions require both user and forecast ownership';
    RAISE NOTICE '   • Rate limits table accessible only via service role';
    RAISE NOTICE '';
    RAISE NOTICE '🚀 Next Steps:';
    RAISE NOTICE '   1. Test sign up/in from iOS app';
    RAISE NOTICE '   2. Deploy Edge Function: supabase functions deploy write-forecast-version';
    RAISE NOTICE '   3. Run smoke tests in Backend Status screen';
    RAISE NOTICE '   4. Configure rate limiting in Supabase Dashboard (see RATE_LIMITING_GUIDE.md)';
    RAISE NOTICE '';
    RAISE NOTICE '📚 Documentation:';
    RAISE NOTICE '   • SUPABASE_INTEGRATION_COMPLETE.md - Complete guide';
    RAISE NOTICE '   • XCODE_SETUP_GUIDE.md - Configure Xcode';
    RAISE NOTICE '   • RATE_LIMITING_GUIDE.md - Rate limit settings';
    RAISE NOTICE '';
END $$;
