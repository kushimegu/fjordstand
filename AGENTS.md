## Project Overview

- FjordBootCamp内向けのクローズドなフリマアプリです。
- Ruby 4.0.5 / Rails 8.1、PostgreSQL、Slim、Tailwind CSS、Hotwireを使用しています。
- 認証と通知にDiscord、画像管理にActive Storage、バックグラウンド処理にSolid Queueを使用しています。
- 商品の状態は`draft`、`published`、`sold`、`closed`です。応募締切後は抽選され、応募者がいない商品は公開終了になります。

## Commands

```sh
bin/setup                         # 初期セットアップ
bin/dev                           # 開発サーバー、CSS、ジョブを起動
bundle exec rspec                 # 全テスト
bundle exec rspec spec/path_spec.rb # 対象テスト
bundle exec rubocop               # Rubyの静的解析
bundle exec slim-lint app/views   # SlimのLint
npm run lint                      # JavaScript / PrettierのLint
```

変更後は、影響するテストと関連するLintを実行してください。

## Boundaries

- 既存のRails構成・命名・書式に合わせ、依頼範囲外のリファクタリングやファイル変更は避けてください。
- データベースの変更は必ずマイグレーションで行い、`db/schema.rb`への直接編集はしないでください。
- 商品の状態遷移、応募締切、抽選、出品者・購入者間のメッセージ閲覧権限を壊さないでください。仕様変更時は関連テストも更新してください。
- Discordのトークン、Webhook URLなどの秘密情報をコードやログに含めず、テストから実際のDiscordへ送信しないでください。
- `.env`、credentials、既存データを不用意に変更・削除しないでください。
