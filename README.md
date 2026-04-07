<img src="feemo_icon.png" width="80" alt="Feemo Icon">

# Feemo

**今の感情を、ひと粒だけ置く感情共有SNS**

写真なし・長文なし。感情をひと言で置いて、友達の空気感をそっと知るミニマルなSNSアプリです。

---

## 概要

Feemoは「何があったか」を投稿するアプリではなく、**「今どう感じているか」を軽く置くアプリ**です。

- 5秒で投稿できる
- 写真なしで成立する
- 友達の今の空気感がわかる
- 比較や承認競争を弱める設計
- 自分の感情ログが残る

**対象ユーザー:** 15〜29歳 / Z世代〜若手社会人

---

## スクリーンショット

| ホーム | 投稿 | グループ | マイページ |
|--------|------|---------|-----------|
| 感情カードフィード | 感情チップ＋強度スライダー | 小グループフィード | 週間サマリー＋感情ログ |

---

## 技術スタック

### iOS
- **Swift / SwiftUI** (iOS 26+)
- **MVVM + Repository パターン**
- `@Observable` (Swift 5.9+)
- Sign in with Apple
- UserNotifications (APNs)

### バックエンド
- **Cloudflare Workers** (TypeScript)
- **Cloudflare D1** (SQLite)
- HMAC-SHA256 JWT 認証
- Apple Identity Token 検証

---

## アーキテクチャ

```
Feemo/
├── Models/          # データモデル (EmotionPost, User, Group, ...)
├── Design/          # DesignTokens (カラー・フォント・スペーシング)
├── State/           # AppState, AuthManager (Sign in with Apple)
├── Network/         # APIClient (actor), APIConfig
├── Repository/      # Protocol + Mock / Live 実装
│   ├── Mock*        # モックデータ（バックエンド不要で動作）
│   └── Live*        # 本番API接続実装
└── Views/
    ├── Home/        # フィード + HomeViewModel
    ├── Post/        # PostComposerSheet + ViewModel
    ├── Group/       # グループ一覧・詳細・作成
    ├── Notification/
    ├── MyPage/      # マイページ・感情ログ・設定
    └── Components/  # EmotionCard, ReactionBar, IntensityDots, UserIcon

backend/
├── src/
│   ├── index.ts        # ルーティング
│   ├── auth.ts         # JWT / Apple Token 検証
│   ├── utils.ts        # レスポンスヘルパー
│   └── routes/
│       ├── auth.ts
│       ├── posts.ts
│       ├── groups.ts
│       ├── notifications.ts
│       └── profile.ts
└── migrations/
    └── 0001_initial.sql  # D1スキーマ（全テーブル＋インデックス）
```

### Mock / Live 自動切替

`APIConfig.swift` の `YOUR_SUBDOMAIN` が未設定の場合はモックデータで動作し、デプロイ済みURLを設定すると自動的に本番APIに切り替わります。

```swift
// Feemo/Network/APIConfig.swift
return "https://feemo-api.YOUR_SUBDOMAIN.workers.dev"
//                      ↑ ここを変更するだけ
```

---

## 画面一覧

| 画面 | 説明 |
|------|------|
| LaunchView | セッション復元 → Auth/Homeへ振り分け |
| AuthView | Sign in with Apple |
| HomeView | 感情カードフィード（スコープ切替・pull to refresh） |
| PostComposerSheet | 感情選択・強度スライダー・メモ・投稿先 |
| GroupListView | グループ一覧 |
| GroupDetailView | グループ別フィード |
| CreateGroupView | グループ作成 |
| NotificationListView | 通知履歴・既読管理 |
| MyPageView | プロフィール・週間サマリー |
| MoodLogView | 日付別感情ログ |
| SettingsView | ニックネーム変更・通知設定・ログアウト |

---

## セットアップ

### iOS

1. Xcode でプロジェクトを開く
2. **Signing & Capabilities** で Sign in with Apple を有効化
3. そのままビルド → モックデータで全画面動作します

### バックエンド (Cloudflare Workers)

詳細は [`backend/SETUP.md`](backend/SETUP.md) を参照。

```bash
# 1. 依存インストール
cd backend && npm install

# 2. Cloudflare 認証
npx wrangler login

# 3. D1 データベース作成
npx wrangler d1 create feemo-db
# → 出力された database_id を wrangler.toml に設定

# 4. JWT シークレット設定（gitには入れない）
openssl rand -hex 32 | npx wrangler secret put JWT_SECRET

# 5. マイグレーション
npm run db:migrate

# 6. デプロイ
npm run deploy
# → https://feemo-api.YOUR_SUBDOMAIN.workers.dev

# 7. iOS側のURLを更新
# Feemo/Network/APIConfig.swift の YOUR_SUBDOMAIN を変更
```

#### ローカル開発

```bash
npm run dev                  # → http://localhost:8787
npm run db:migrate:local     # ローカルD1にマイグレーション
npm run db:seed:local        # テストデータ投入
```

---

## API エンドポイント

| Method | Path | 説明 |
|--------|------|------|
| POST | `/auth/apple` | Apple認証・ユーザー作成 |
| POST | `/auth/logout` | ログアウト |
| GET | `/posts/feed` | フィード取得（scope / cursor対応） |
| POST | `/posts` | 感情投稿 |
| GET | `/posts/mine` | 自分の投稿 |
| DELETE | `/posts/:id` | 投稿削除 |
| POST | `/posts/:id/reactions` | リアクション追加 |
| DELETE | `/posts/:id/reactions/:type` | リアクション削除 |
| GET | `/groups` | グループ一覧 |
| POST | `/groups` | グループ作成 |
| GET | `/groups/:id/feed` | グループフィード |
| GET | `/notifications` | 通知一覧 |
| PATCH | `/notifications/:id/read` | 既読 |
| PATCH | `/notifications/read-all` | 全既読 |
| GET | `/me/mood-log` | 感情ログ |
| GET | `/me/mood-summary/week` | 週間サマリー |
| PATCH | `/me/nickname` | ニックネーム変更 |
| POST | `/devices/register` | APNsトークン登録 |

---

## セキュリティ

- **JWT_SECRET** は `wrangler secret put` で管理（gitに含めない）
- 投稿の削除は本人のみ可
- グループフィードはメンバーのみアクセス可
- Apple Identity Token の issuer / audience / expiry を検証

---

## 今後の実装予定

- [ ] メンバー招待（招待コード）
- [ ] APNs プッシュ通知送信（Cloudflare Queues）
- [ ] 月間サマリー
- [ ] 感情ログのフィルター・カレンダー表示
- [ ] プレミアム機能導線

---

## ライセンス

MIT
