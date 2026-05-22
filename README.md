# FjordStand

<img width="1126" height="402" alt="fjordstand-image" src="https://github.com/user-attachments/assets/bfe85896-ba90-4b1b-91d7-7c6dc63aa3f9" />

## サービス概要

FjordBootCamp (FBC) 内の人に不用品を安く譲って役立ててもらいたい、FBC 関係者向けのクローズドなフリマアプリです。

- 出品者は購入希望申請期間を設けて商品を出品できます
- 締切日時になると購入希望者から自動的に抽選が行われ、購入者が決定します
- 購入確定後は出品者・購入者間の連絡ページでやり取りができます

## サービスURL

https://fjordstand.com

## 使い方

出品するボタンから商品情報を入力して出品します。購入希望の申請締切は選択した日付の23時59分に設定されます。

<img width="874" height="644" alt="スクリーンショット 2026-05-21 17 50 39" src="https://github.com/user-attachments/assets/87ddee7c-166f-4994-ab70-74014da8edac" />

購入希望の申請締切日を過ぎると自動で抽選が行われ、希望者の中から購入者が決定します。抽選は毎日8時頃に行われます。

<img width="876" height="538" alt="スクリーンショット 2026-05-21 17 51 05" src="https://github.com/user-attachments/assets/f1b9962d-cb59-4cfb-b0a9-b66820e44132" />

購入確定後は非公開の連絡ページで出品者と購入者の間でやり取りし、外部のサービスを使用して送金および商品の発送を行ってください。

<img width="698" height="473" alt="スクリーンショット 2026-05-21 17 51 25" src="https://github.com/user-attachments/assets/1ed495e1-04ee-4114-89f7-f2027c123752" />

出品した商品およびコメントした商品はWatch中の状態になり、一覧で見る事ができる他、その商品に新しいコメントが投稿された際にDiscordおよびアプリ内で通知を受け取る事ができます。（Watchはボタンから登録・解除することもできます。）

Discordで受け取る通知にはメンションがついており、抽選結果やコメント、メッセージの見逃し防止に役立ちます。

<img width="330" height="223" alt="スクリーンショット 2026-05-21 18 10 38" src="https://github.com/user-attachments/assets/66169cf2-e14a-422c-9edf-05cc52d48357" />

## 技術スタック

| カテゴリ               | 技術                                      |
| ---------------------- | ----------------------------------------- |
| 言語                   | Ruby 4.0.5                                |
| フレームワーク         | Ruby on Rails 8.1                         |
| データベース           | PostgreSQL                                |
| フロントエンド         | Tailwind CSS / Hotwire (Turbo + Stimulus) |
| テンプレート           | Slim                                      |
| 認証                   | Discord OAuth (OmniAuth)                  |
| 画像処理               | Active Storage + libvips                  |
| バックグラウンドジョブ | Solid Queue                               |
| テスト                 | RSpec / Capybara                          |

## 開発環境のセットアップ

### 前提条件

以下をインストールしておいてください。

- **Ruby** 4.0.5（[rbenv](https://github.com/rbenv/rbenv) または [asdf](https://asdf-vm.com/) 推奨）
- **PostgreSQL**
- **libvips**（画像処理に使用）

  ```sh
  # macOS
  brew install vips

  # Ubuntu / Debian
  sudo apt-get install libvips
  ```

- **Node.js**（npm が使えれば OK）

### 手順

```sh
# 1. リポジトリをクローン
git clone <repository-url>
cd fjordstand

# 2. 環境変数を設定（後述）
cp .env.example .env
# .env を編集して値を埋める

# 3. 初期セットアップとサーバー起動
bin/setup
```

### 環境変数の設定

`.env` ファイルに以下の環境変数を設定してください。Discord アプリの作成方法は後述します。

```
DISCORD_CLIENT_ID=
DISCORD_CLIENT_SECRET=
DISCORD_REDIRECT_URI=
DISCORD_BOT_TOKEN=
DISCORD_SERVER_ID=
WEBHOOK_URL=
ERROR_WEBHOOK_URL=
```

### Discord アプリの設定

このアプリは Discord OAuth でログインします。開発用の Discord アプリを作成してください。

1. [Discord Developer Portal](https://discord.com/developers/applications) で新しいアプリを作成
2. **OAuth2** の設定画面で Redirect URI に `http://localhost:3000/auth/discord/callback` を追加
3. **Client ID** と **Client Secret** を `.env` の `DISCORD_CLIENT_ID` / `DISCORD_CLIENT_SECRET` に設定
4. `DISCORD_REDIRECT_URI` に `http://localhost:3000/auth/discord/callback` を設定
5. Bot を作成してトークンを `DISCORD_BOT_TOKEN` に設定
6. 開発に使用する Discord サーバーの ID を `DISCORD_SERVER_ID` に設定
7. Discord チャンネル設定の Webhook 画面から URL を取得し、`DISCORD_WEBHOOK_URL` に設定
8. ジョブに失敗した際に通知を受け取る Discord チャンネルの Webhook 画面から URL を取得し、`ERROR_WEBHOOK_URL` に設定

## 開発サーバーの起動

```sh
bin/dev
```

以下のプロセスがまとめて起動します（`Procfile.dev` で定義）。

| プロセス | 内容                                  |
| -------- | ------------------------------------- |
| `web`    | Rails サーバー（ポート 3000）         |
| `css`    | Tailwind CSS のウォッチ               |
| `jobs`   | Solid Queue（バックグラウンドジョブ） |

ブラウザで http://localhost:3000 を開いてください。

## テストの実行

```sh
# 全テスト
bundle exec rspec

# 特定のファイルのみ
bundle exec rspec spec/models/item_spec.rb
```

## コードスタイル

```sh
# Ruby
bundle exec rubocop

# Slim テンプレート
bundle exec slim-lint app/views

# JavaScript の構文・フォーマットチェック（ESLint / Prettier）
npm run lint
```
