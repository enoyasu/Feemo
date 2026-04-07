# Feemo 実装仕様書

## 0. このドキュメントの目的

このドキュメントは、iPhoneアプリ **Feemo** を実装するための仕様書である。  
Claude Code / Codex にそのまま渡し、実装を進められる粒度で整理している。

目的は以下の通り。

- MVPを最短で作る
- 個人開発で運営可能な構成にする
- 将来的に10万MAU規模まで伸ばせる設計にする
- 最初から作り込みすぎず、コア体験に集中する
- UIはミニマルでやわらかく、若者向けだが子どもっぽくしない
- 写真SNSやチャットSNSにはしない
- 「感情を置くSNS」として一貫性を保つ

---

## 1. プロダクト概要

### アプリ名
**Feemo**

### コンセプト
**今の感情を、言葉よりも軽く投稿して共有するSNS**

### コア価値
- 写真なしでも成立する
- 5秒で投稿できる
- 感情だけを軽く置ける
- 友達の空気感がわかる
- 比較や承認競争を弱める
- 自分の感情ログが残る

### このアプリの本質
Feemoは「何があったか」を投稿するアプリではない。  
**「今どう感じているか」を、感情の粒として置くアプリ**である。

---

## 2. 対象ユーザー

### メインターゲット
- 15〜29歳
- Z世代〜若手社会人
- Instagram / BeReal / X / LINE を使っている
- 写真投稿や長文投稿には少し疲れている
- 重い自己開示はしたくないが、軽く共有したい

### 代表的なユースケース
- しんどいけど文章を書く気力はない
- 気分だけ誰かに置いておきたい
- 友達の今の空気感だけ知りたい
- 深い会話はしないが、つながりたい
- 毎日1回は開く軽いSNSが欲しい

---

## 3. MVPの範囲

この仕様書で実装するのは **MVP** のみ。  
MVPでは以下を作る。

### 実装対象
1. Sign in with Apple 認証
2. 感情投稿
3. 感情カード型フィード
4. 感情リアクション
5. 小グループ
6. 自分用感情ログ
7. Push通知
8. 基本的な設定画面

### 実装しないもの
- 写真投稿
- 動画投稿
- 長文日記
- フォロワー数
- 公開おすすめフィード
- 位置情報共有
- ライブ配信
- DMチャット
- 電話番号認証
- AI診断機能
- 課金実装（MVPでは不要。導線だけ後で追加可能な設計にする）

---

## 4. 技術スタック

### iOS
- Swift
- SwiftUI
- iOS 17 以上を優先対象
- NavigationStack ベース
- MVVMベースで構成
- View / ViewModel / Repository / APIClient を分離

### Backend
- Cloudflare Workers
- Cloudflare D1
- Cloudflare Queues
- Cloudflare KV（必要時のみ）
- APNs

### 認証
- Sign in with Apple

### 方針
- 常時リアルタイム接続は使わない
- WebSocketは使わない
- フィード更新は軽い pull / refresh ベース
- Push通知で再訪問を促す
- テキスト中心の軽量構成にする

---

## 5. 情報設計

### タブ構成
下部タブは以下の4つにする。

1. ホーム
2. グループ
3. 通知
4. マイページ

### 画面一覧
- LaunchView
- AuthView
- HomeView
- PostComposerSheet
- GroupListView
- GroupDetailView
- NotificationListView
- MyPageView
- MoodLogView
- SettingsView
- CreateGroupView

---

## 6. 画面仕様

## 6-1. LaunchView
### 目的
- 初回起動判定
- 認証済みか確認
- 未認証なら AuthView に遷移
- 認証済みなら MainTabView に遷移

### 要件
- 起動時に現在の認証状態を確認
- ローディングはシンプル
- ブランドロゴと背景だけでよい

---

## 6-2. AuthView
### 目的
- Sign in with Apple でログインする

### UI要素
- アプリロゴ
- キャッチコピー
- Sign in with Apple ボタン
- 利用規約 / プライバシーポリシーへの導線（プレースホルダ可）

### 実装要件
- Apple認証成功後、バックエンドにトークン送信
- ユーザーを作成または既存ログイン
- 認証状態を保持
- 初回だけニックネーム設定画面へ遷移してもよいが、MVPでは省略可

---

## 6-3. HomeView
### 目的
- 感情投稿を最短で行う
- 友達やグループの感情フィードを見る

### UI要素
- 画面上部タイトル「Feemo」またはグループ名
- グループ切り替えセグメント
  - すべて
  - 親しい友達
  - 各グループ
- 今日の投稿ボタン
- 同期投稿タイムの小さな案内
- 感情カード一覧
- pull to refresh

### 重要な要件
- 一番上に「いまの気分を置く」導線を固定表示
- 投稿導線はタップしやすく大きく
- フィードは軽量でよい
- 画像は使わない
- フィードは最新20件程度から開始、ページング対応可
- 空状態では優しい文言を表示

### 空状態例
- まだ感情が置かれていません
- 最初のひと粒を置いてみよう

---

## 6-4. PostComposerSheet
### 目的
- 5秒で感情投稿する

### UI要素
1. 感情選択チップ一覧
2. 強度スライダー（1〜5）
3. 一言メモ入力（任意、最大40文字程度）
4. 投稿先選択
   - 親しい友達
   - グループ
   - 自分だけ
5. 投稿ボタン

### 初期感情候補
- うれしい
- しずか
- そわそわ
- ねむい
- 焦り
- 虚無
- 回復中
- むり
- 満たされ
- さみしい

### 挙動
- 感情選択は必須
- 強度はデフォルト3
- メモは任意
- 投稿成功後は sheet を閉じる
- 投稿成功後、ホームのフィードを先頭更新
- 連投制限は将来入れられる設計にするが、MVPでは不要

---

## 6-5. GroupListView
### 目的
- 所属グループ一覧を見る
- グループを作成する
- グループ詳細へ移動する

### UI要素
- グループ一覧
- 各グループの最新投稿時刻
- 未読っぽい簡易表示（本実装が重ければ後回し可）
- 新規グループ作成ボタン

### グループ要件
- グループ名
- メンバー数
- 最新ムードの色味またはラベル
- 招待リンクまたはコード機能は将来対応。MVPでは簡易実装可

---

## 6-6. GroupDetailView
### 目的
- 特定グループの感情フィードを閲覧する
- そのグループ向けに投稿する

### UI要素
- グループ名
- メンバー一覧の簡易表示
- 投稿ボタン
- グループ専用感情カード一覧

### 要件
- HomeView のフィード構造を再利用してよい
- 投稿時に group_id を持たせる
- グループ削除 / 退会は MVPでは最低限でよい

---

## 6-7. NotificationListView
### 目的
- 通知履歴を一覧する

### 通知種別
- リアクションされた
- グループに招待された
- 同期投稿タイムが始まった
- 自分の投稿に反応がついた

### UI要素
- 通知一覧
- 既読/未読の見た目差分
- タップで該当投稿または該当グループへ遷移

### 要件
- Push通知とアプリ内通知一覧の両方に対応
- MVPでは通知保存期間は短くてよい

---

## 6-8. MyPageView
### 目的
- 自分の感情履歴と傾向を簡単に見る
- 設定画面に行く

### UI要素
- プロフィール（ニックネーム、アイコン色）
- 直近の感情履歴
- よく使う感情
- 週間サマリー（簡易）
- 設定ボタン
- 将来のプレミアム導線を置けるスペース

### MVP要件
- まずは直近7日が見られればよい
- 複雑な分析は不要
- 簡単な統計だけ表示する

---

## 6-9. MoodLogView
### 目的
- 自分の過去投稿を一覧で見る

### UI要素
- 日付ごとの区切り
- 感情ラベル
- 強度
- メモ
- 投稿先種別

### 要件
- 自分の投稿のみ表示
- 並び順は新しい順
- 将来的なフィルタに備えた構造にしてよいが、MVPでは未実装でよい

---

## 6-10. SettingsView
### 目的
- 最低限の設定を行う

### 項目
- ニックネーム変更
- 通知オン/オフ
- 同期投稿通知オン/オフ
- ログアウト
- 規約 / ポリシー導線

### MVP要件
- 複雑な設定は不要
- 最低限動けばよい

---

## 6-11. CreateGroupView
### 目的
- 小グループを作る

### UI要素
- グループ名入力
- メンバー追加（MVPでは将来的に簡易でよい）
- 作成ボタン

### MVP簡略案
最初は「グループ作成だけ可能」「メンバー招待は後で追加」でもよい。  
ただし、将来的に invite を足しやすいデータ構造にはしておく。

---

## 7. UIデザイン仕様

### デザインキーワード
- ミニマル
- やわらかい
- 余白多め
- フラット
- 若者向け
- 子どもっぽすぎない
- 感情的だが重くない

### カラー方針
ベースカラー候補
- くすみラベンダー
- ペールブルー
- スモーキーピンク
- くすみミント

### コンポーネント方針
- 角丸大きめ
- シャドウは最小限
- 枠線は薄く
- 感情カードは色で差分を出す
- 絵文字依存にしすぎない
- テキスト量は少なく
- 余白で気持ちよさを出す

### フィードカードの見た目
カードに含めるもの
- ユーザー名
- 感情ラベル
- 強度表示
- 一言メモ（任意）
- 時刻
- リアクション導線

### 強度の表現
1〜5の強度は以下いずれかで表現
- 塗りの濃さ
- 波の量
- 小さなドットの数

派手にしすぎず、視認できる程度に抑えること。

---

## 8. データモデル仕様

## 8-1. users
- id: string
- apple_user_id: string
- nickname: string
- icon_color: string
- created_at: datetime
- updated_at: datetime

## 8-2. groups
- id: string
- name: string
- owner_user_id: string
- created_at: datetime
- updated_at: datetime

## 8-3. group_members
- id: string
- group_id: string
- user_id: string
- role: string
- created_at: datetime

## 8-4. emotion_posts
- id: string
- user_id: string
- group_id: string nullable
- emotion_primary: string
- emotion_secondary: string nullable
- intensity: integer
- short_note: string nullable
- visibility_scope: string
- created_at: datetime
- expires_at: datetime nullable

### visibility_scope の候補
- close_friends
- group
- private

## 8-5. post_reactions
- id: string
- post_id: string
- reactor_user_id: string
- reaction_type: string
- created_at: datetime

## 8-6. device_tokens
- id: string
- user_id: string
- apns_token: string
- created_at: datetime

## 8-7. notifications
- id: string
- user_id: string
- type: string
- title: string
- body: string
- related_post_id: string nullable
- related_group_id: string nullable
- is_read: boolean
- created_at: datetime

## 8-8. daily_user_mood_summary
- id: string
- user_id: string
- summary_date: date
- top_emotions: string
- post_count: integer
- mood_score: integer nullable

---

## 9. DBインデックス方針

最低限、以下のインデックスを作ること。

- emotion_posts(user_id, created_at DESC)
- emotion_posts(group_id, created_at DESC)
- post_reactions(post_id, created_at DESC)
- notifications(user_id, created_at DESC)
- group_members(group_id, user_id)

理由：
- フィード取得
- 自分ログ取得
- グループフィード取得
- 通知一覧取得

---

## 10. API仕様

## 10-1. 認証

### POST /auth/apple
#### 役割
- Apple認証トークンを受け取り、ユーザーを作成またはログインさせる

#### request
- identityToken
- authorizationCode
- nickname optional

#### response
- accessToken
- user

### POST /auth/logout
#### 役割
- ローカルセッションクリア用
- サーバー側で特別な処理が不要なら空実装でもよい

---

## 10-2. 投稿

### POST /posts
#### request
- emotionPrimary: string
- emotionSecondary: string optional
- intensity: number
- shortNote: string optional
- visibilityScope: string
- groupId: string optional

#### validation
- emotionPrimary は必須
- intensity は 1〜5
- shortNote は最大40文字程度
- visibilityScope が group の場合は groupId 必須

#### response
- created post object

### GET /posts/feed
#### query
- scope: all / close_friends / group
- groupId optional
- cursor optional
- limit optional

#### response
- posts
- nextCursor optional

### GET /posts/mine
#### query
- cursor optional
- limit optional

### DELETE /posts/:id
#### 要件
- 自分の投稿のみ削除可能

---

## 10-3. リアクション

### POST /posts/:id/reactions
#### request
- reactionType

#### allowed reactionType
- wakaru
- gyu
- erai
- mimamoru
- shindosou
- ureshii

### DELETE /posts/:id/reactions/:reactionType
#### 要件
- 自分がつけたもののみ削除可能

---

## 10-4. グループ

### GET /groups
- 自分が所属するグループ一覧を返す

### POST /groups
#### request
- name

### POST /groups/:id/invite
MVPではダミーでもよい。  
将来の招待用にAPIの枠だけ残してもよい。

### GET /groups/:id/feed
- そのグループの投稿一覧を返す

---

## 10-5. 通知

### GET /notifications
- 自分の通知一覧を返す

### PATCH /notifications/:id/read
- 個別既読

### PATCH /notifications/read-all
- 一括既読

---

## 10-6. デバイストークン

### POST /devices/register
#### request
- apnsToken

### DELETE /devices/:id
- ログアウト時やトークン破棄時に使用可能

---

## 10-7. ログ・集計

### GET /me/mood-log
- 自分の投稿一覧

### GET /me/mood-summary/week
- 直近7日集計

### GET /me/mood-summary/month
- MVPでは将来実装でもよい
- APIだけ空けておいてもよい

---

## 11. 通知仕様

### Push通知の目的
- 再訪問を促す
- 同期投稿タイムを知らせる
- 自分の投稿への反応を知らせる

### 通知種別
1. 同期投稿通知
2. リアクション通知
3. グループ関連通知

### 同期投稿通知の文言例
- 今の気分、置いてって
- いま何色？
- いまの感情を、ひと粒
- いまの温度だけ残そう

### 通知方針
- 送りすぎない
- 1日2〜3回まで
- 深夜帯は避ける
- 通知オン/オフ設定を用意

---

## 12. 状態管理とアーキテクチャ

### 推奨構成
- AppState
- AuthManager
- SessionStore
- APIClient
- Repository層
- ViewModel層
- SwiftUI View層

### 役割
#### AppState
- アプリ全体のログイン状態やルート制御

#### AuthManager
- Apple認証
- トークン管理

#### APIClient
- Workers API 通信共通処理
- 認証ヘッダ付与
- エラー処理統一

#### Repository
- posts
- groups
- notifications
- profile
などの責務分離

#### ViewModel
- 各画面ごとの表示状態管理
- 非同期処理のハブ

### 注意
View内にビジネスロジックを埋め込みすぎないこと。

---

## 13. 実装順序

以下の順序で実装すること。

### Step 1
- プロジェクト作成
- タブ構成だけ作る
- 仮の画面遷移を作る

### Step 2
- Sign in with Apple 実装
- セッション管理
- LaunchView / AuthView 連携

### Step 3
- 投稿モーダル実装
- 感情投稿API実装
- Homeフィード表示

### Step 4
- リアクション機能実装
- 投稿削除機能実装
- 自分ログ画面実装

### Step 5
- グループ一覧
- グループ詳細フィード
- グループ作成

### Step 6
- 通知一覧
- APNs登録
- Push通知受信

### Step 7
- 設定画面
- ニックネーム編集
- 通知設定

### Step 8
- UI調整
- エンプティステート
- エラーハンドリング
- ローディング整備

---

## 14. ローディング / エラー / 空状態

### ローディング
- 画面全体ローディングは最小限
- フィードは skeleton ではなく簡易 placeholder でもよい

### エラー
- ユーザーに見せる文言はやさしく短く
- 技術的な詳細は表示しない

### エラー文例
- 読み込みに失敗しました
- 投稿できませんでした
- もう一度お試しください

### 空状態
- やわらかい文言にする
- 誘導を置く

例
- まだ誰も気持ちを置いていません
- 最初のひと粒を置いてみよう

---

## 15. 非機能要件

### パフォーマンス
- フィード初回表示は軽く
- 投稿は体感1秒以内が理想
- 不要な再描画を避ける
- 画像を使わないので描画は軽く保つ

### 保守性
- 画面ごとにViewModel分離
- コンポーネント分割
- API定義をまとめる
- 色やフォントは DesignToken 的に管理

### セキュリティ
- 認証トークンは安全に保存
- 自分の投稿だけ削除できる
- 所属していないグループにはアクセスできない
- 不正な group_id / post_id の検証を行う

---

## 16. デザイン禁止事項

以下はやらないこと。

- 情報量を増やしすぎる
- 写真SNSっぽくする
- チャットアプリっぽくする
- ネオンや派手な装飾を使いすぎる
- 子どもっぽいポップデザインにしすぎる
- 絵文字依存にしすぎる
- フォロワー数やランキングを出す
- 承認競争を強める設計にする

---

## 17. 実装時の最重要思想

実装時は、以下を常に優先すること。

1. 投稿が最短で終わること
2. 投稿後すぐに他人の感情が見えること
3. UIが軽くやさしいこと
4. 「盛る」方向に行かないこと
5. 既存SNSと同じ競争構造を入れないこと

Feemoの強みは、  
**“感情を軽く置ける” という一点にある。**

機能を増やして価値を作るのではなく、  
**必要最小限で体験の純度を上げる**こと。

---

## 18. 今回の実装ゴール

この仕様でまず完成させるべきゴールは以下。

- Appleログインできる
- 感情を投稿できる
- 感情カードを見られる
- リアクションできる
- 小グループで見られる
- 自分の感情ログを見られる
- 通知で戻ってこられる

ここまでで MVP 完成とする。

---

## 19. Codex / Claude Code への実装指示

以下の方針で実装を進めること。

- まずは iOSアプリ側の画面骨格を作る
- モックデータで画面を先に成立させる
- その後API接続に差し替える
- コンポーネントは再利用しやすく分割する
- デザインはミニマルで統一する
- 各画面にPreviewを用意する
- APIクライアントは差し替え可能にする
- TODOコメントを適切に残す
- MVP範囲外は実装しない
- 迷ったら「軽く・少なく・やさしく」を優先する

---

## 20. 最終要約

Feemoは、  
**感情を投稿するのではなく、感情をひと粒置くSNS**である。

実装では、写真・公開競争・複雑な機能を避け、  
以下の体験に絞ること。

- 5秒で投稿
- 軽く共有
- 小さくつながる
- 自分の感情も残る

このアプリは、盛るためのSNSではなく、  
**今の気持ちを軽く置くためのミニマルなSNS**として実装すること。
