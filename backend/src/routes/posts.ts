import { Env, EmotionPost, PostReaction } from '../types';
import { requireAuth } from '../auth';
import { jsonResponse, errorResponse, generateId, parseBody, getCursor, getLimit } from '../utils';

interface CreatePostRequest {
  emotion_primary: string;
  emotion_secondary?: string;
  intensity: number;
  short_note?: string;
  visibility_scope: string;
  group_id?: string;
}

interface ReactionRequest {
  reaction_type: string;
}

const ALLOWED_SCOPES = ['close_friends', 'group', 'private'];
const ALLOWED_REACTIONS = ['wakaru', 'gyu', 'erai', 'mimamoru', 'shindosou', 'ureshii'];

async function getReactionsForPosts(postIds: string[], env: Env): Promise<Map<string, PostReaction[]>> {
  if (postIds.length === 0) return new Map();

  const placeholders = postIds.map(() => '?').join(',');
  const rows = await env.DB
    .prepare(`SELECT * FROM post_reactions WHERE post_id IN (${placeholders}) ORDER BY created_at DESC`)
    .bind(...postIds)
    .all<PostReaction>();

  const map = new Map<string, PostReaction[]>();
  for (const reaction of (rows.results ?? [])) {
    const list = map.get(reaction.post_id) ?? [];
    list.push(reaction);
    map.set(reaction.post_id, list);
  }
  return map;
}

export async function handleGetFeed(request: Request, env: Env): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  const url = new URL(request.url);
  const scope = url.searchParams.get('scope') ?? 'all';
  const groupId = url.searchParams.get('group_id');
  const cursor = getCursor(url);
  const limit = getLimit(url);

  let query: string;
  let bindings: unknown[];

  if (scope === 'group' && groupId) {
    // Verify membership
    const member = await env.DB
      .prepare('SELECT 1 FROM group_members WHERE group_id = ? AND user_id = ?')
      .bind(groupId, userId)
      .first();
    if (!member) return errorResponse('Not a member of this group', 403);

    query = `
      SELECT ep.*, u.nickname as author_nickname, u.icon_color as author_icon_color
      FROM emotion_posts ep
      JOIN users u ON ep.user_id = u.id
      WHERE ep.group_id = ? AND ep.visibility_scope = 'group'
      ${cursor ? 'AND ep.created_at < ?' : ''}
      ORDER BY ep.created_at DESC
      LIMIT ?
    `;
    bindings = cursor ? [groupId, cursor, limit + 1] : [groupId, limit + 1];
  } else {
    // Close friends feed: users in same groups as current user + own posts
    query = `
      SELECT DISTINCT ep.*, u.nickname as author_nickname, u.icon_color as author_icon_color
      FROM emotion_posts ep
      JOIN users u ON ep.user_id = u.id
      WHERE ep.visibility_scope = 'close_friends'
        AND ep.user_id IN (
          SELECT DISTINCT gm2.user_id FROM group_members gm1
          JOIN group_members gm2 ON gm1.group_id = gm2.group_id
          WHERE gm1.user_id = ?
        )
      ${cursor ? 'AND ep.created_at < ?' : ''}
      ORDER BY ep.created_at DESC
      LIMIT ?
    `;
    bindings = cursor ? [userId, cursor, limit + 1] : [userId, limit + 1];
  }

  const rows = await env.DB.prepare(query).bind(...bindings).all<EmotionPost>();
  const posts = rows.results ?? [];
  const hasMore = posts.length > limit;
  if (hasMore) posts.pop();

  const reactionsMap = await getReactionsForPosts(posts.map(p => p.id), env);
  const postsWithReactions = posts.map(p => ({
    ...p,
    reactions: reactionsMap.get(p.id) ?? [],
  }));

  return jsonResponse({
    posts: postsWithReactions,
    next_cursor: hasMore ? posts[posts.length - 1]?.created_at ?? null : null,
  });
}

export async function handleCreatePost(request: Request, env: Env): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  let body: CreatePostRequest;
  try {
    body = await parseBody<CreatePostRequest>(request);
  } catch {
    return errorResponse('Invalid request body');
  }

  // Validation
  if (!body.emotion_primary?.trim()) return errorResponse('emotion_primary is required');
  if (!body.intensity || body.intensity < 1 || body.intensity > 5) return errorResponse('intensity must be 1-5');
  if (!ALLOWED_SCOPES.includes(body.visibility_scope)) return errorResponse('Invalid visibility_scope');
  if (body.visibility_scope === 'group' && !body.group_id) return errorResponse('group_id required for group scope');
  if (body.short_note && body.short_note.length > 40) return errorResponse('short_note max 40 characters');

  if (body.group_id) {
    const member = await env.DB
      .prepare('SELECT 1 FROM group_members WHERE group_id = ? AND user_id = ?')
      .bind(body.group_id, userId)
      .first();
    if (!member) return errorResponse('Not a member of this group', 403);
  }

  const id = generateId();
  const now = new Date().toISOString();

  await env.DB
    .prepare(`
      INSERT INTO emotion_posts
        (id, user_id, group_id, emotion_primary, emotion_secondary, intensity, short_note, visibility_scope, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `)
    .bind(
      id, userId, body.group_id ?? null,
      body.emotion_primary, body.emotion_secondary ?? null,
      body.intensity, body.short_note ?? null,
      body.visibility_scope, now
    )
    .run();

  const user = await env.DB
    .prepare('SELECT nickname, icon_color FROM users WHERE id = ?')
    .bind(userId)
    .first<{ nickname: string; icon_color: string }>();

  return jsonResponse({
    id, user_id: userId,
    group_id: body.group_id ?? null,
    emotion_primary: body.emotion_primary,
    emotion_secondary: body.emotion_secondary ?? null,
    intensity: body.intensity,
    short_note: body.short_note ?? null,
    visibility_scope: body.visibility_scope,
    created_at: now,
    expires_at: null,
    reactions: [],
    author_nickname: user?.nickname ?? 'ユーザー',
    author_icon_color: user?.icon_color ?? 'A8D8C0',
  }, 201);
}

export async function handleGetMyPosts(request: Request, env: Env): Promise<Response> {
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

  const reactionsMap = await getReactionsForPosts(posts.map(p => p.id), env);
  const postsWithReactions = posts.map(p => ({
    ...p,
    reactions: reactionsMap.get(p.id) ?? [],
  }));

  return jsonResponse({
    posts: postsWithReactions,
    next_cursor: hasMore ? posts[posts.length - 1]?.created_at ?? null : null,
  });
}

export async function handleDeletePost(request: Request, env: Env, postId: string): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  const post = await env.DB
    .prepare('SELECT user_id FROM emotion_posts WHERE id = ?')
    .bind(postId)
    .first<{ user_id: string }>();

  if (!post) return errorResponse('Post not found', 404);
  if (post.user_id !== userId) return errorResponse('Forbidden', 403);

  await env.DB.prepare('DELETE FROM emotion_posts WHERE id = ?').bind(postId).run();
  return jsonResponse({ ok: true });
}

export async function handleAddReaction(request: Request, env: Env, postId: string): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  let body: ReactionRequest;
  try {
    body = await parseBody<ReactionRequest>(request);
  } catch {
    return errorResponse('Invalid request body');
  }

  if (!ALLOWED_REACTIONS.includes(body.reaction_type)) return errorResponse('Invalid reaction_type');

  const post = await env.DB
    .prepare('SELECT id, user_id, visibility_scope FROM emotion_posts WHERE id = ?')
    .bind(postId)
    .first<{ id: string; user_id: string; visibility_scope: string }>();

  if (!post) return errorResponse('Post not found', 404);

  const id = generateId();
  try {
    await env.DB
      .prepare('INSERT INTO post_reactions (id, post_id, reactor_user_id, reaction_type) VALUES (?, ?, ?, ?)')
      .bind(id, postId, userId, body.reaction_type)
      .run();
  } catch {
    return errorResponse('Already reacted with this reaction', 409);
  }

  // Create notification for post author (if not self-reaction)
  if (post.user_id !== userId) {
    await env.DB
      .prepare(`
        INSERT INTO notifications (id, user_id, type, title, body, related_post_id)
        VALUES (?, ?, 'reaction', ?, ?, ?)
      `)
      .bind(
        generateId(), post.user_id,
        'リアクションされました',
        `「${body.reaction_type}」をもらいました`,
        postId
      )
      .run();
  }

  return jsonResponse({ ok: true }, 201);
}

export async function handleRemoveReaction(
  request: Request, env: Env, postId: string, reactionType: string
): Promise<Response> {
  const userId = await requireAuth(request, env);
  if (!userId) return errorResponse('Unauthorized', 401);

  await env.DB
    .prepare('DELETE FROM post_reactions WHERE post_id = ? AND reactor_user_id = ? AND reaction_type = ?')
    .bind(postId, userId, reactionType)
    .run();

  return jsonResponse({ ok: true });
}
