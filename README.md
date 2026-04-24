# FjordStand

## サービス概要

FjordBootCamp (FBC) 内の人に不用品を安く譲って役立ててもらいたい、FBC 関係者向けのクローズドなフリマアプリです。

- 出品者は購入希望申請期間を設けて商品を出品できます
- 締切日時になると購入希望者から自動的に抽選が行われ、購入者が決定します
- 購入確定後は出品者・購入者間の連絡ページでやり取りができます

## 技術スタック

| カテゴリ               | 技術                                      |
| ---------------------- | ----------------------------------------- |
| 言語                   | Ruby 4.0.1                                |
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

- **Ruby** 4.0.1（[rbenv](https://github.com/rbenv/rbenv) または [asdf](https://asdf-vm.com/) 推奨）
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

# 2. gem をインストール
bundle install

# 3. npm パッケージをインストール
npm install

# 4. 環境変数を設定（後述）
cp .env.example .env
# .env を編集して値を埋める

# 5. データベースを作成・マイグレート・シードデータ投入
bin/rails db:create db:migrate db:seed
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
```
