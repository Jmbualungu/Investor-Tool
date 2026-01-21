// Write Forecast Version with Rate Limiting
// Enforces per-user write limits to prevent abuse
//
// Rate Limits:
// - Max 30 writes per 5 minutes per user
// - Max 5 writes per minute per user
//
// Returns 429 (Too Many Requests) if limit exceeded

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface RateLimitConfig {
  key: string
  maxCount: number
  windowMinutes: number
}

const RATE_LIMITS: RateLimitConfig[] = [
  { key: 'write-forecast-version-5min', maxCount: 30, windowMinutes: 5 },
  { key: 'write-forecast-version-1min', maxCount: 5, windowMinutes: 1 },
]

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get Authorization header
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Create Supabase client with service role (bypasses RLS for rate limit checks)
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      global: { headers: { Authorization: authHeader } }
    })

    // Verify user is authenticated
    const { data: { user }, error: authError } = await supabase.auth.getUser(
      authHeader.replace('Bearer ', '')
    )

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const userId = user.id

    // Parse request body
    const body = await req.json()
    const { forecast_id, assumptions, results, note } = body

    if (!forecast_id || !assumptions) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: forecast_id, assumptions' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check rate limits
    for (const limit of RATE_LIMITS) {
      const rateLimitResult = await checkRateLimit(supabase, userId, limit)
      
      if (!rateLimitResult.allowed) {
        return new Response(
          JSON.stringify({
            error: 'Rate limit exceeded',
            message: `Too many requests. Maximum ${limit.maxCount} per ${limit.windowMinutes} minute(s).`,
            retryAfter: rateLimitResult.retryAfter,
          }),
          {
            status: 429,
            headers: {
              ...corsHeaders,
              'Content-Type': 'application/json',
              'Retry-After': rateLimitResult.retryAfter.toString(),
            },
          }
        )
      }
    }

    // Verify forecast belongs to user (RLS check)
    const { data: forecast, error: forecastError } = await supabase
      .from('forecasts')
      .select('id, user_id')
      .eq('id', forecast_id)
      .eq('user_id', userId)
      .single()

    if (forecastError || !forecast) {
      return new Response(
        JSON.stringify({ error: 'Forecast not found or access denied' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Insert forecast version
    const { data: version, error: insertError } = await supabase
      .from('forecast_versions')
      .insert({
        forecast_id,
        user_id: userId,
        assumptions,
        results: results || null,
        note: note || null,
      })
      .select()
      .single()

    if (insertError) {
      console.error('Insert error:', insertError)
      return new Response(
        JSON.stringify({ error: 'Failed to create version', details: insertError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Increment rate limit counters
    for (const limit of RATE_LIMITS) {
      await incrementRateLimit(supabase, userId, limit)
    }

    return new Response(
      JSON.stringify({ data: version }),
      { status: 201, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Function error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error', details: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

// ============================================================================
// RATE LIMITING LOGIC
// ============================================================================

interface RateLimitResult {
  allowed: boolean
  retryAfter: number  // seconds
}

async function checkRateLimit(
  supabase: any,
  userId: string,
  config: RateLimitConfig
): Promise<RateLimitResult> {
  const windowStart = getWindowStart(config.windowMinutes)
  
  // Get current count for this window
  const { data, error } = await supabase
    .from('rate_limits')
    .select('count')
    .eq('user_id', userId)
    .eq('key', config.key)
    .eq('window_start', windowStart.toISOString())
    .single()

  if (error && error.code !== 'PGRST116') {  // PGRST116 = no rows
    console.error('Rate limit check error:', error)
    // Fail open (allow request) if there's a DB error
    return { allowed: true, retryAfter: 0 }
  }

  const currentCount = data?.count || 0

  if (currentCount >= config.maxCount) {
    // Calculate retry after (seconds until window expires)
    const windowEnd = new Date(windowStart.getTime() + config.windowMinutes * 60 * 1000)
    const retryAfter = Math.ceil((windowEnd.getTime() - Date.now()) / 1000)
    
    return { allowed: false, retryAfter }
  }

  return { allowed: true, retryAfter: 0 }
}

async function incrementRateLimit(
  supabase: any,
  userId: string,
  config: RateLimitConfig
): Promise<void> {
  const windowStart = getWindowStart(config.windowMinutes)

  // Upsert: increment if exists, insert with count=1 if not
  await supabase.rpc('increment_rate_limit', {
    p_user_id: userId,
    p_key: config.key,
    p_window_start: windowStart.toISOString(),
  })
}

function getWindowStart(windowMinutes: number): Date {
  const now = new Date()
  const minutes = Math.floor(now.getMinutes() / windowMinutes) * windowMinutes
  return new Date(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours(), minutes, 0, 0)
}

/* 
 * SQL Function for incrementing rate limits (add to migration):
 * 
 * CREATE OR REPLACE FUNCTION increment_rate_limit(
 *   p_user_id UUID,
 *   p_key TEXT,
 *   p_window_start TIMESTAMPTZ
 * )
 * RETURNS void AS $$
 * BEGIN
 *   INSERT INTO rate_limits (user_id, key, window_start, count)
 *   VALUES (p_user_id, p_key, p_window_start, 1)
 *   ON CONFLICT (user_id, key, window_start)
 *   DO UPDATE SET count = rate_limits.count + 1;
 * END;
 * $$ LANGUAGE plpgsql SECURITY DEFINER;
 */
