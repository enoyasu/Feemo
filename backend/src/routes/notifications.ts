import { Env, Notification } from '../types';
import { requireAuth } from '../auth';
import { jsonResponse, errorResponse } from '../utils';

export async function handleGetNotifications(request: Request, env: Env): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  const rows = await env.DB
    .prepare(`
      SELECT * FROM notifications
      WHERE user_id = ?
      ORDER BY created_at DESC
      LIMIT 50
    `)
    .bind(userId)
    .all<Notification>();

  const notifications = (rows.results ?? []).map(n => ({
    ...n,
    is_read: n.is_read === true || (n.is_read as unknown) === 1,
  }));

  return jsonResponse({ notifications });
}

export async function handleMarkRead(request: Request, env: Env, notificationId: string): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  await env.DB
    .prepare('UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?')
    .bind(notificationId, userId)
    .run();

  return jsonResponse({ ok: true });
}

export async function handleMarkAllRead(request: Request, env: Env): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  await env.DB
    .prepare('UPDATE notifications SET is_read = 1 WHERE user_id = ?')
    .bind(userId)
    .run();

  return jsonResponse({ ok: true });
}
