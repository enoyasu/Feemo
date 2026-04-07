import { Env, User } from '../types';
import { createJWT, verifyAppleToken } from '../auth';
import { jsonResponse, errorResponse, generateId, parseBody } from '../utils';

interface AppleAuthRequest {
  identity_token: string;
  authorization_code: string;
  nickname?: string;
}

export async function handleAppleAuth(request: Request, env: Env): Promise<Response> {
  let body: AppleAuthRequest;
  try {
    body = await parseBody<AppleAuthRequest>(request);
  } catch {
    return errorResponse('Invalid request body');
  }

  if (!body.identity_token) {
    return errorResponse('identity_token is required');
  }

  // Verify Apple identity token
  const appleUserId = await verifyAppleToken(body.identity_token, env.APPLE_CLIENT_ID);
  if (!appleUserId) {
    return errorResponse('Invalid Apple identity token', 401);
  }

  // Upsert user
  const existingUser = await env.DB
    .prepare('SELECT * FROM users WHERE apple_user_id = ?')
    .bind(appleUserId)
    .first<User>();

  let user: User;
  if (existingUser) {
    user = existingUser;
  } else {
    const userId = generateId();
    const nickname = body.nickname?.trim() || 'ユーザー';
    const iconColors = ['A8D8C0', 'A8C8E8', 'F9C784', 'C3B1D8', 'E8A0A0', 'F4A96A'];
    const iconColor = iconColors[Math.floor(Math.random() * iconColors.length)];

    await env.DB
      .prepare('INSERT INTO users (id, apple_user_id, nickname, icon_color) VALUES (?, ?, ?, ?)')
      .bind(userId, appleUserId, nickname, iconColor)
      .run();

    user = {
      id: userId,
      apple_user_id: appleUserId,
      nickname,
      icon_color: iconColor,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };
  }

  const accessToken = await createJWT(user.id, env.JWT_SECRET);

  return jsonResponse({
    access_token: accessToken,
    user: {
      id: user.id,
      nickname: user.nickname,
      icon_color: user.icon_color,
      created_at: user.created_at,
    },
  });
}

export async function handleLogout(_request: Request, _env: Env): Promise<Response> {
  // Stateless JWT - client just discards the token
  return jsonResponse({ ok: true });
}
