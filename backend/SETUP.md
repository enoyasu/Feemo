# Feemo Backend セットアップガイド

## 前提条件
- Node.js 18+
- Cloudflare アカウント
- `wrangler` CLI: `npm install -g wrangler`

## 1. Cloudflare 認証

```bash
npx wrangler login
```

## 2. D1 データベース作成

```bash
npx wrangler d1 create feemo-db
```

出力された `database_id` を `wrangler.toml` の `database_id` に設定する。

## 3. マイグレーション実行

```bash
# ローカル（開発用）
npm run db:migrate:local

# 本番
npm run db:migrate
```

## 4. シークレット設定

```bash
# JWT署名用シークレット（32バイトのランダム文字列）
openssl rand -hex 32 | npx wrangler secret put JWT_SECRET
```

## 5. ローカル開発

```bash
npm run dev
# → http://localhost:8787 で起動
```

iOSアプリ側は DEBUG ビルドで自動的に `http://localhost:8787` を向く。

## 6. 本番デプロイ

```bash
npm run deploy
# → https://feemo-api.YOUR_SUBDOMAIN.workers.dev にデプロイ
```

デプロイ後、iOS側の `APIConfig.swift` の `YOUR_SUBDOMAIN` を実際のサブドメインに置き換える。

```swift
// Feemo/Network/APIConfig.swift
return "https://feemo-api.actual-subdomain.workers.dev"
```

## 7. APNs (プッシュ通知) — 将来実装

Cloudflare Queues を使って APNs 送信を非同期処理する予定。
`wrangler.toml` の queues セクションを参照。

## エンドポイント一覧

| Method | Path | 説明 |
|--------|------|------|
| POST | /auth/apple | Apple認証 |
| POST | /auth/logout | ログアウト |
| GET | /posts/feed | フィード取得 |
| POST | /posts | 投稿作成 |
| GET | /posts/mine | 自分の投稿 |
| DELETE | /posts/:id | 投稿削除 |
| POST | /posts/:id/reactions | リアクション追加 |
| DELETE | /posts/:id/reactions/:type | リアクション削除 |
| GET | /groups | グループ一覧 |
| POST | /groups | グループ作成 |
| GET | /groups/:id/feed | グループフィード |
| POST | /groups/:id/invite | 招待（将来実装） |
| GET | /notifications | 通知一覧 |
| PATCH | /notifications/:id/read | 既読 |
| PATCH | /notifications/read-all | 全既読 |
| GET | /me/mood-log | 感情ログ |
| GET | /me/mood-summary/week | 週間サマリー |
| PATCH | /me/nickname | ニックネーム変更 |
| POST | /devices/register | デバイストークン登録 |
| DELETE | /devices/:id | デバイストークン削除 |
