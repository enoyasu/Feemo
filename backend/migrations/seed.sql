-- Development seed data (local only)
INSERT OR IGNORE INTO users (id, apple_user_id, nickname, icon_color)
VALUES
  ('u1', 'apple_u1', 'あなた', 'A8D8C0'),
  ('u2', 'apple_u2', 'みお', 'A8C8E8'),
  ('u3', 'apple_u3', 'りく', 'E8A0A0'),
  ('u4', 'apple_u4', 'はるか', 'F9C784'),
  ('u5', 'apple_u5', 'そうた', 'C3B1D8');

INSERT OR IGNORE INTO groups (id, name, owner_user_id)
VALUES
  ('g1', '大学の友達', 'u1'),
  ('g2', '高校クラス', 'u2');

INSERT OR IGNORE INTO group_members (id, group_id, user_id, role)
VALUES
  ('gm1', 'g1', 'u1', 'owner'),
  ('gm2', 'g1', 'u2', 'member'),
  ('gm3', 'g1', 'u3', 'member'),
  ('gm4', 'g2', 'u2', 'owner'),
  ('gm5', 'g2', 'u4', 'member');

INSERT OR IGNORE INTO emotion_posts (id, user_id, emotion_primary, intensity, short_note, visibility_scope)
VALUES
  ('p1', 'u2', 'しずか', 3, 'ゆっくりした朝', 'close_friends'),
  ('p2', 'u3', 'むり', 4, NULL, 'close_friends'),
  ('p3', 'u4', 'うれしい', 5, 'テスト終わった！！', 'close_friends'),
  ('p4', 'u5', 'ねむい', 2, NULL, 'close_friends');

INSERT OR IGNORE INTO post_reactions (id, post_id, reactor_user_id, reaction_type)
VALUES
  ('r1', 'p2', 'u1', 'gyu'),
  ('r2', 'p3', 'u2', 'ureshii'),
  ('r3', 'p3', 'u3', 'erai');
