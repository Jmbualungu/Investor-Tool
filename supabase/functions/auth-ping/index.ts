// Auth Ping Edge Function
// Purpose: Validate JWT tokens sent from iOS app (debugging endpoint)
// Usage: GET /auth-ping with Authorization: Bearer <token>

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Extract Authorization header
    const authHeader = req.headers.get('Authorization')
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return new Response(
        JSON.stringify({
          ok: false,
          error: 'Missing or invalid Authorization header',
          hint: 'Expected: Authorization: Bearer <token>',
        }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // Extract token
    const token = authHeader.replace('Bearer ', '')

    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Validate JWT by fetching user
    const { data: { user }, error } = await supabase.auth.getUser(token)

    if (error || !user) {
      return new Response(
        JSON.stringify({
          ok: false,
          error: error?.message || 'Invalid or expired token',
          code: error?.code || 'INVALID_TOKEN',
        }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // Token is valid
    return new Response(
      JSON.stringify({
        ok: true,
        userId: user.id,
        email: user.email,
        metadata: {
          emailVerified: user.email_confirmed_at !== null,
          lastSignIn: user.last_sign_in_at,
          createdAt: user.created_at,
        },
        message: 'Token is valid',
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  } catch (error) {
    console.error('Auth ping error:', error)
    
    return new Response(
      JSON.stringify({
        ok: false,
        error: 'Internal server error',
        details: error instanceof Error ? error.message : 'Unknown error',
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})

/* Usage Examples:

1. Valid Token:
   Request:
     GET https://xyz.supabase.co/functions/v1/auth-ping
     Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

   Response (200):
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

2. Missing Token:
   Request:
     GET https://xyz.supabase.co/functions/v1/auth-ping

   Response (401):
     {
       "ok": false,
       "error": "Missing or invalid Authorization header",
       "hint": "Expected: Authorization: Bearer <token>"
     }

3. Invalid Token:
   Request:
     GET https://xyz.supabase.co/functions/v1/auth-ping
     Authorization: Bearer invalid_token

   Response (401):
     {
       "ok": false,
       "error": "Invalid or expired token",
       "code": "INVALID_TOKEN"
     }

4. Testing with curl (local):
   # Start Supabase locally
   supabase start

   # Get a valid token (sign in via iOS app or use Supabase Studio)
   TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

   # Test auth-ping
   curl http://localhost:54321/functions/v1/auth-ping \
     -H "Authorization: Bearer $TOKEN"

5. Testing with curl (production):
   curl https://xyz.supabase.co/functions/v1/auth-ping \
     -H "Authorization: Bearer $TOKEN"

*/
