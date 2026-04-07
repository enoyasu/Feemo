export interface Env {
  DB: D1Database;
  APPLE_TEAM_ID: string;
  APPLE_CLIENT_ID: string;
  JWT_SECRET: string;
}

export interface JWTPayload {
  sub: string; // user id
  exp: number;
  iat: number;
}

export interface User {
  id: string;
  apple_user_id: string;
  nickname: string;
  icon_color: string;
  created_at: string;
  updated_at: string;
}

export interface EmotionPost {
  id: string;
  user_id: string;
  group_id: string | null;
  emotion_primary: string;
  emotion_secondary: string | null;
  intensity: number;
  short_note: string | null;
  visibility_scope: 'close_friends' | 'group' | 'private';
  created_at: string;
  expires_at: string | null;
  author_nickname?: string;
  author_icon_color?: string;
  reactions?: PostReaction[];
}

export interface PostReaction {
  id: string;
  post_id: string;
  reactor_user_id: string;
  reaction_type: string;
  created_at: string;
}

export interface Group {
  id: string;
  name: string;
  owner_user_id: string;
  member_count?: number;
  latest_post_at?: string | null;
  latest_emotion?: string | null;
  created_at: string;
}

export interface Notification {
  id: string;
  user_id: string;
  type: string;
  title: string;
  body: string;
  related_post_id: string | null;
  related_group_id: string | null;
  is_read: boolean;
  created_at: string;
}
