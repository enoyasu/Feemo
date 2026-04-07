import { Env, EmotionPost } from '../types';
import { requireAuth } from '../auth';
import { jsonResponse, errorResponse, generateId, parseBody, getCursor, getLimit } from '../utils';

interface UpdateNicknameRequest {
  nickname: string;
}

interface RegisterDeviceRequest {
  apns_token: string;
}

export async function handleGetMoodLog(request: Request, env: Env): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  const url = new URL(request.url);
  const cursor = getCursor(url);
  const limit = getLimit(url);

  const query = `
    SELECT ep.*, u.nickname as author_nickname, u.icon_color as author_icon_color
    FROM emotion_posts ep
    JOIN users u ON ep.user_id = u.id
    WHERE ep.user_id = ?
    ${cursor ? 'AND ep.created_at < ?' : ''}
    ORDER BY ep.created_at DESC
    LIMIT ?
  `;
  const bindings = cursor ? [userId, cursor, limit + 1] : [userId, limit + 1];

  const rows = await env.DB.prepare(query).bind(...bindings).all<EmotionPost>();
  const posts = rows.results ?? [];
  const hasMore = posts.length > limit;
  if (hasMore) posts.pop();

  return jsonResponse({
    posts,
    next_cursor: hasMore ? posts[posts.length - 1]?.created_at ?? null : null,
  });
}

export async function handleWeeklySummary(request: Request, env: Env): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();

  const rows = await env.DB
    .prepare(`
      SELECT emotion_primary, COUNT(*) as count
      FROM emotion_posts
      WHERE user_id = ? AND created_at >= ?
      GROUP BY emotion_primary
      ORDER BY count DESC
      LIMIT 3
    `)
    .bind(userId, sevenDaysAgo)
    .all<{ emotion_primary: string; count: number }>();

  const countRow = await env.DB
    .prepare('SELECT COUNT(*) as total FROM emotion_posts WHERE user_id = ? AND created_at >= ?')
    .bind(userId, sevenDaysAgo)
    .first<{ total: number }>();

  return jsonResponse({
    post_count: countRow?.total ?? 0,
    top_emotions: (rows.results ?? []).map(r => r.emotion_primary),
    mood_score: null,
  });
}

export async function handleMonthSummary(request: Request, env: Env): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);
  // TODO: Monthly summary
  return jsonResponse({ post_count: 0, top_emotions: [], mood_score: null });
}

export async function handleUpdateNickname(request: Request, env: Env): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  let body: UpdateNicknameRequest;
  try {
    body = await parseBody<UpdateNicknameRequest>(request);
  } catch {
    return errorResponse('Invalid request body');
  }

  const nickname = body.nickname?.trim();
  if (!nickname) return errorResponse('nickname is required');
  if (nickname.length > 20) return errorResponse('nickname max 20 characters');

  await env.DB
    .prepare('UPDATE users SET nickname = ?, updated_at = ? WHERE id = ?')
    .bind(nickname, new Date().toISOString(), userId)
    .run();

  const user = await env.DB
    .prepare('SELECT * FROM users WHERE id = ?')
    .bind(userId)
    .first();

  return jsonResponse({ user });
}

export async function handleRegisterDevice(request: Request, env: Env): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  let body: RegisterDeviceRequest;
  try {
    body = await parseBody<RegisterDeviceRequest>(request);
  } catch {
    return errorResponse('Invalid request body');
  }

  if (!body.apns_token) return errorResponse('apns_token is required');

  const id = generateId();
  await env.DB
    .prepare('INSERT OR REPLACE INTO device_tokens (id, user_id, apns_token) VALUES (?, ?, ?)')
    .bind(id, userId, body.apns_token)
    .run();

  return jsonResponse({ ok: true }, 201);
}

export async function handleDeleteDevice(request: Request, env: Env, deviceId: string): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  await env.DB
    .prepare('DELETE FROM device_tokens WHERE id = ? AND user_id = ?')
    .bind(deviceId, userId)
    .run();

  return jsonResponse({ ok: true });
}
