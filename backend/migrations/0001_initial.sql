-- Users table
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  apple_user_id TEXT UNIQUE NOT NULL,
  nickname TEXT NOT NULL DEFAULT 'ユーザー',
  icon_color TEXT NOT NULL DEFAULT 'A8D8C0',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Groups table
CREATE TABLE IF NOT EXISTS groups (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  owner_user_id TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (owner_user_id) REFERENCES users(id)
);

-- Group members table
CREATE TABLE IF NOT EXISTS group_members (
  id TEXT PRIMARY KEY,
  group_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'member',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (group_id) REFERENCES groups(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  UNIQUE(group_id, user_id)
);

-- Emotion posts table
CREATE TABLE IF NOT EXISTS emotion_posts (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  group_id TEXT,
  emotion_primary TEXT NOT NULL,
  emotion_secondary TEXT,
  intensity INTEGER NOT NULL CHECK (intensity BETWEEN 1 AND 5),
  short_note TEXT CHECK (length(short_note) <= 40),
  visibility_scope TEXT NOT NULL DEFAULT 'close_friends'
    CHECK (visibility_scope IN ('close_friends', 'group', 'private')),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  expires_at TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (group_id) REFERENCES groups(id)
);

-- Post reactions table
CREATE TABLE IF NOT EXISTS post_reactions (
  id TEXT PRIMARY KEY,
  post_id TEXT NOT NULL,
  reactor_user_id TEXT NOT NULL,
  reaction_type TEXT NOT NULL
    CHECK (reaction_type IN ('wakaru', 'gyu', 'erai', 'mimamoru', 'shindosou', 'ureshii')),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (post_id) REFERENCES emotion_posts(id) ON DELETE CASCADE,
  FOREIGN KEY (reactor_user_id) REFERENCES users(id),
  UNIQUE(post_id, reactor_user_id, reaction_type)
);

-- Device tokens for APNs
CREATE TABLE IF NOT EXISTS device_tokens (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  apns_token TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id),
  UNIQUE(user_id, apns_token)
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  related_post_id TEXT,
  related_group_id TEXT,
  is_read INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Daily mood summary (materialized for performance)
CREATE TABLE IF NOT EXISTS daily_user_mood_summary (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  summary_date TEXT NOT NULL,
  top_emotions TEXT NOT NULL DEFAULT '[]',
  post_count INTEGER NOT NULL DEFAULT 0,
  mood_score INTEGER,
  FOREIGN KEY (user_id) REFERENCES users(id),
  UNIQUE(user_id, summary_date)
);

-- Indexes per spec section 9
CREATE INDEX IF NOT EXISTS idx_emotion_posts_user_created
  ON emotion_posts(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_emotion_posts_group_created
  ON emotion_posts(group_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_post_reactions_post_created
  ON post_reactions(post_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_user_created
  ON notifications(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_group_members_group_user
  ON group_members(group_id, user_id);
