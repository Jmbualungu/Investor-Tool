// Supabase Edge Function: delete-account
//
// Permanently deletes the authenticated user's account (App Store guideline 5.1.1(v)).
// The caller's JWT identifies the user; the service-role key performs the deletion.
//
// Deploy:  supabase functions deploy delete-account
// Secrets: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are injected automatically.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return json({ error: "Missing Authorization header" }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    // Identify the caller from their JWT.
    const userClient = createClient(supabaseUrl, serviceKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const {
      data: { user },
      error: userError,
    } = await userClient.auth.getUser();

    if (userError || !user) {
      return json({ error: "Invalid or expired session" }, 401);
    }

    // Delete the auth user with the service role. ON DELETE CASCADE on
    // user-owned tables (auth.users -> public.*) removes their data.
    const admin = createClient(supabaseUrl, serviceKey);
    const { error: deleteError } = await admin.auth.admin.deleteUser(user.id);
    if (deleteError) {
      return json({ error: deleteError.message }, 500);
    }

    return json({ success: true }, 200);
  } catch (err) {
    return json({ error: String(err) }, 500);
  }
});

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
