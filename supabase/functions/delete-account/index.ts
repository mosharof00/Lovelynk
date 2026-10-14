// Permanently deletes the calling user's account.
// The users_before_delete trigger archives the couple and notifies the partner.
import { createClient, type SupabaseClient } from 'npm:@supabase/supabase-js@2';

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });

function secretKey(): string {
  const legacy = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (legacy) return legacy;
  const keys = JSON.parse(Deno.env.get('SUPABASE_SECRET_KEYS') ?? '{}');
  return keys.default ?? Object.values(keys)[0];
}

async function listFiles(
  admin: SupabaseClient,
  bucket: string,
  prefix: string,
): Promise<string[]> {
  const { data, error } = await admin.storage.from(bucket).list(prefix, { limit: 1000 });
  if (error || !data) return [];
  const paths: string[] = [];
  for (const item of data) {
    const path = `${prefix}/${item.name}`;
    // Folders have no id; recurse into them.
    if (item.id == null) {
      paths.push(...(await listFiles(admin, bucket, path)));
    } else {
      paths.push(path);
    }
  }
  return paths;
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  const token = req.headers.get('Authorization')?.replace('Bearer ', '');
  if (!token) return json({ error: 'Not authenticated' }, 401);

  const admin = createClient(Deno.env.get('SUPABASE_URL')!, secretKey(), {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data: userData, error: userError } = await admin.auth.getUser(token);
  const user = userData?.user;
  if (userError || !user) return json({ error: 'Not authenticated' }, 401);

  const role = user.app_metadata?.role;
  if (role != null && role !== 'user') {
    return json({ error: 'This account cannot be deleted from the app' }, 403);
  }

  for (const bucket of ['avatars', 'support-attachments']) {
    const paths = await listFiles(admin, bucket, user.id);
    if (paths.length > 0) {
      const { error } = await admin.storage.from(bucket).remove(paths);
      if (error) console.error(`[delete-account] ${bucket} cleanup failed`, error.message);
    }
  }

  const { error: deleteError } = await admin.auth.admin.deleteUser(user.id);
  if (deleteError) {
    console.error('[delete-account] deleteUser failed', deleteError.message);
    return json({ error: 'Could not delete the account. Please try again.' }, 500);
  }

  return json({ deleted: true });
});
