import { Env, Group } from '../types';
import { requireAuth } from '../auth';
import { jsonResponse, errorResponse, generateId, parseBody } from '../utils';

interface CreateGroupRequest {
  name: string;
}

export async function handleGetGroups(request: Request, env: Env): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  const rows = await env.DB
    .prepare(`
      SELECT g.*,
        COUNT(gm2.user_id) as member_count,
        MAX(ep.created_at) as latest_post_at,
        (SELECT ep2.emotion_primary FROM emotion_posts ep2
         WHERE ep2.group_id = g.id ORDER BY ep2.created_at DESC LIMIT 1) as latest_emotion
      FROM groups g
      JOIN group_members gm ON g.id = gm.group_id AND gm.user_id = ?
      LEFT JOIN group_members gm2 ON g.id = gm2.group_id
      LEFT JOIN emotion_posts ep ON g.id = ep.group_id
      GROUP BY g.id
      ORDER BY latest_post_at DESC NULLS LAST
    `)
    .bind(userId)
    .all<Group>();

  return jsonResponse({ groups: rows.results ?? [] });
}

export async function handleCreateGroup(request: Request, env: Env): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  let body: CreateGroupRequest;
  try {
    body = await parseBody<CreateGroupRequest>(request);
  } catch {
    return errorResponse('Invalid request body');
  }

  if (!body.name?.trim()) return errorResponse('name is required');
  if (body.name.length > 50) return errorResponse('name max 50 characters');

  const groupId = generateId();
  const now = new Date().toISOString();

  await env.DB.batch([
    env.DB.prepare('INSERT INTO groups (id, name, owner_user_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?)')
      .bind(groupId, body.name.trim(), userId, now, now),
    env.DB.prepare('INSERT INTO group_members (id, group_id, user_id, role, created_at) VALUES (?, ?, ?, ?, ?)')
      .bind(generateId(), groupId, userId, 'owner', now),
  ]);

  return jsonResponse({
    id: groupId,
    name: body.name.trim(),
    owner_user_id: userId,
    member_count: 1,
    latest_post_at: null,
    latest_emotion: null,
    created_at: now,
    updated_at: now,
  }, 201);
}

export async function handleGetGroupFeed(request: Request, env: Env, groupId: string): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  const member = await env.DB
    .prepare('SELECT 1 FROM group_members WHERE group_id = ? AND user_id = ?')
    .bind(groupId, userId)
    .first();
  if (!member) return errorResponse('Not a member of this group', 403);

  const url = new URL(request.url);
  const cursor = url.searchParams.get('cursor');
  const limit = Math.min(parseInt(url.searchParams.get('limit') ?? '20', 10), 50);

  const query = `
    SELECT ep.*, u.nickname as author_nickname, u.icon_color as author_icon_color
    FROM emotion_posts ep
    JOIN users u ON ep.user_id = u.id
    WHERE ep.group_id = ?
    ${cursor ? 'AND ep.created_at < ?' : ''}
    ORDER BY ep.created_at DESC
    LIMIT ?
  `;
  const bindings = cursor ? [groupId, cursor, limit + 1] : [groupId, limit + 1];

  const rows = await env.DB.prepare(query).bind(...bindings).all();
  const posts = rows.results ?? [];
  const hasMore = posts.length > limit;
  if (hasMore) posts.pop();

  return jsonResponse({
    posts,
    next_cursor: hasMore ? (posts[posts.length - 1] as Record<string, unknown>)?.created_at ?? null : null,
  });
}

export async function handleGroupInvite(request: Request, env: Env, groupId: string): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  // TODO: Generate invite link / code for future implementation
  return jsonResponse({
    invite_code: groupId.slice(0, 8).toUpperCase(),
    message: '招待機能は近日公開予定です',
  });
}
