# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

unless Rails.env.development?
  puts "Skipping seed data (not development environment)"
  return
end

require "open-uri"

puts "=== Seeding development data ==="

# 既存データを削除（冪等性のため）
[Notification, Comment, Watch, Entry, Message, Item].each(&:destroy_all)
User.where("uid LIKE 'dev_%'").destroy_all

# ユーザー作成
puts "Creating users..."

users_data = [
  { name: "田中 太郎",   uid: "dev_001", avatar_url: "https://i.pravatar.cc/150?img=11" },
  { name: "佐藤 花子",   uid: "dev_002", avatar_url: "https://i.pravatar.cc/150?img=5"  },
  { name: "鈴木 一郎",   uid: "dev_003", avatar_url: "https://i.pravatar.cc/150?img=8"  },
  { name: "山田 美咲",   uid: "dev_004", avatar_url: "https://i.pravatar.cc/150?img=47" },
  { name: "伊藤 健太",   uid: "dev_005", avatar_url: "https://i.pravatar.cc/150?img=15" },
  { name: "渡辺 さくら", uid: "dev_006", avatar_url: "https://i.pravatar.cc/150?img=25" },
]

dev_users = users_data.map do |attrs|
  User.find_or_create_by!(uid: attrs[:uid]) do |u|
    u.name       = attrs[:name]
    u.provider   = "discord"
    u.avatar_url = attrs[:avatar_url]
  end
end

# ログイン済みの実ユーザーがいればそちらを me として使う
real_user = User.where.not(uid: users_data.map { |u| u[:uid] }).first
me     = real_user || dev_users[0]
others = dev_users.reject { |u| u == me }

puts "me: #{me.name} (#{me.uid})"

# 商品データ
puts "Creating items..."

items_data = [
  # --- 出品中（締切あり・未来） ---
  {
    title: "プログラミング入門書セット（Ruby・Rails・JavaScript）",
    description: "3冊まとめて。書き込みなし、状態良好です。\n\nRuby超入門 / Rails実践ガイド / JavaScript完全攻略 の3冊セットです。購入から2年ほど経ちますが読み込んだ形跡はほぼありません。",
    price: 1_500,
    shipping_fee_payer: :buyer,
    payment_method: "PayPay または 銀行振込",
    status: :published,
    entry_deadline_at: 7.days.from_now,
    user: others[0],
  },
  {
    title: "MacBook Air 充電器 USB-C 61W",
    description: "MacBook Air M1 に付属していた純正充電器です。買い替えに伴い不要になりました。動作確認済みです。",
    price: 3_000,
    shipping_fee_payer: :seller,
    payment_method: "PayPay",
    status: :published,
    entry_deadline_at: 3.days.from_now,
    user: others[1],
  },
  {
    title: "モニタースタンド（木製・高さ調整可）",
    description: "デスク整理のために購入しましたが、モニターアームに変えたので不要になりました。傷などはありません。",
    price: 2_000,
    shipping_fee_payer: :buyer,
    payment_method: "PayPay",
    status: :published,
    entry_deadline_at: 10.days.from_now,
    user: others[2],
  },
  {
    title: "ワイヤレスキーボード HHKB Professional HYBRID",
    description: "HHKB Professional HYBRID Type-S（英字配列・墨）です。使用期間は約1年。キーの摩耗はほぼなく、外観もきれいです。",
    price: 18_000,
    shipping_fee_payer: :seller,
    payment_method: "銀行振込",
    status: :published,
    entry_deadline_at: 5.days.from_now,
    user: others[3],
  },
  {
    title: "デスクライト（LED・色温度調整付き）",
    description: nil,
    price: 1_200,
    shipping_fee_payer: :buyer,
    payment_method: "PayPay",
    status: :published,
    entry_deadline_at: 14.days.from_now,
    user: others[4],
  },
  {
    title: "プログラマーのためのSQL徹底攻略",
    description: "SQLの基礎から応用まで網羅した書籍です。付箋が数枚貼ってありますが、書き込みはありません。",
    price: 800,
    shipping_fee_payer: :buyer,
    payment_method: "PayPay",
    status: :published,
    entry_deadline_at: 4.days.from_now,
    user: others[0],
  },
  {
    title: "ノイズキャンセリングヘッドフォン SONY WH-1000XM4",
    description: "在宅勤務用に購入しましたが、イヤーピース型に変えたため手放します。バッテリーの持ちも問題なし。付属品（ケーブル・ポーチ・充電ケーブル）一式つきます。",
    price: 15_000,
    shipping_fee_payer: :seller,
    payment_method: "PayPay または 銀行振込",
    status: :published,
    entry_deadline_at: 6.days.from_now,
    user: others[1],
  },
  {
    title: "iPad スタンド（折り畳み式・アルミ）",
    description: nil,
    price: 600,
    shipping_fee_payer: :buyer,
    payment_method: "PayPay",
    status: :published,
    entry_deadline_at: 8.days.from_now,
    user: others[2],
  },

  # --- 出品中（締切あり・締切間近） ---
  {
    title: "技術書典で買った同人誌まとめ（5冊）",
    description: "技術書典で購入した同人誌5冊セットです。テーマはRust・Go・Webフロントエンド・設計・DDD。すべて未読です。",
    price: 2_500,
    shipping_fee_payer: :buyer,
    payment_method: "PayPay",
    status: :published,
    entry_deadline_at: 1.day.from_now,
    user: others[3],
  },

  # --- 自分が出品した商品（出品中） ---
  {
    title: "古いプログラミング本（PHP・Python入門）",
    description: "数年前に購入した入門書です。今は使う機会がないので譲ります。",
    price: 500,
    shipping_fee_payer: :buyer,
    payment_method: "PayPay",
    status: :published,
    entry_deadline_at: 5.days.from_now,
    user: me,
  },
  # --- 自分が出品（購入者確定） ---
  {
    title: "Logicool マウス MX Master 3",
    description: "1年使用したLogicoolのMX Master 3です。動作確認済み。付属USBレシーバーあり。",
    price: 5_000,
    shipping_fee_payer: :seller,
    payment_method: "PayPay",
    status: :sold,
    entry_deadline_at: 10.days.ago,
    user: me,
  },
  # --- 他人が出品（自分が購入した商品） ---
  {
    title: "iPad mini 第6世代 Wi-Fi 64GB スペースグレイ",
    description: "1年半ほど使用しました。画面に目立つ傷はなく、動作も問題ありません。Apple純正ケースとペンシル第2世代も一緒にお譲りします。",
    price: 45_000,
    shipping_fee_payer: :seller,
    payment_method: "銀行振込",
    status: :sold,
    entry_deadline_at: 14.days.ago,
    user: others[2],
  },
  # --- 自分が出品（公開終了） ---
  {
    title: "古いHDMIケーブル 2m×2本",
    description: "引越しで不要になりました。動作問題なし。",
    price: 300,
    shipping_fee_payer: :buyer,
    payment_method: "PayPay",
    status: :closed,
    entry_deadline_at: 30.days.ago,
    user: me,
  },
  # --- 自分の下書き ---
  {
    title: "外付けSSD 500GB（使用少なめ）",
    description: nil,
    price: nil,
    shipping_fee_payer: nil,
    payment_method: nil,
    status: :draft,
    entry_deadline_at: nil,
    user: me,
  },
  {
    title: nil,
    description: nil,
    price: nil,
    shipping_fee_payer: nil,
    payment_method: nil,
    status: :draft,
    entry_deadline_at: nil,
    user: me,
  },
]

items = items_data.map do |attrs|
  Item.create!(
    title:              attrs[:title],
    description:        attrs[:description],
    price:              attrs[:price],
    shipping_fee_payer: attrs[:shipping_fee_payer],
    payment_method:     attrs[:payment_method],
    status:             attrs[:status],
    entry_deadline_at:  attrs[:entry_deadline_at]&.end_of_day,
    user:               attrs[:user],
  )
end

# 画像添付（下書きと無題アイテム以外）
puts "Attaching images..."

# picsum.photos の seed 番号（商品ごとに固定の画像になるよう seed を指定）
image_seeds = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120]

items.each_with_index do |item, idx|
  next if item.draft? && item.title.nil?

  seed = image_seeds[idx % image_seeds.size]
  begin
    file = URI.open("https://picsum.photos/seed/#{seed}/400/400")
    item.images.attach(
      io: file,
      filename: "item-#{idx + 1}.jpg",
      content_type: "image/jpeg"
    )
    print "."
  rescue => e
    puts "\nSkipped image for '#{item.title}': #{e.message}"
  end
end
puts " done"

published_by_others = items.select { |i| i.published? && i.user != me }
sold_item           = items.find { |i| i.sold? && i.user == me }
bought_item         = items.find { |i| i.sold? && i.user != me }  # 自分が購入した商品
my_published        = items.find { |i| i.published? && i.user == me }

# 応募（Entry）
puts "Creating entries..."

# 自分が応募している商品（購入希望中）
applied_items = published_by_others.first(3)
applied_items.each do |item|
  Entry.create!(user: me, item: item, status: :applied)
end

# 自分が購入確定した商品
won_item = published_by_others[3]
Entry.create!(user: me, item: won_item, status: :won)

# 自分が落選した商品
lost_item = published_by_others[4]
Entry.create!(user: me, item: lost_item, status: :lost)

# 他ユーザーが自分の出品に応募
[others[1], others[2], others[3]].each do |user|
  Entry.create!(user: user, item: my_published, status: :applied)
end

# 自分の売却済み商品の当選者・落選者（バリデーションスキップ）
Entry.new(user: others[0], item: sold_item, status: :won).tap { |e| e.save(validate: false) }
[others[1], others[2]].each do |user|
  Entry.new(user: user, item: sold_item, status: :lost).tap { |e| e.save(validate: false) }
end

# 自分が購入した商品（me が当選者）
Entry.new(user: me,        item: bought_item, status: :won).tap  { |e| e.save(validate: false) }
Entry.new(user: others[0], item: bought_item, status: :lost).tap { |e| e.save(validate: false) }
Entry.new(user: others[1], item: bought_item, status: :lost).tap { |e| e.save(validate: false) }

# Watch
puts "Creating watches..."

watch_items = published_by_others.first(4)
watch_items.each do |item|
  Watch.create!(user: me, item: item)
end

# 自分の出品にwatchしているユーザー
Watch.create!(user: others[0], item: my_published)

# コメント
puts "Creating comments..."

commentable_items = published_by_others.first(3)

commentable_items[0].tap do |item|
  Comment.create!(user: others[1], item: item, body: "状態について教えていただけますか？カバーに傷などはありますか？")
  Comment.create!(user: item.user,  item: item, body: "カバーは若干の使用感がありますが、中身は綺麗です。よろしくお願いします！")
  Comment.create!(user: me,         item: item, body: "送料はどのくらいかかりますか？")
  Comment.create!(user: item.user,  item: item, body: "発送はゆうメールを予定しています。200円程度になると思います。")
end

commentable_items[1].tap do |item|
  Comment.create!(user: me,        item: item, body: "まだ応募できますか？")
  Comment.create!(user: item.user, item: item, body: "はい、締切まで応募受け付けています。よろしくお願いします！")
end

commentable_items[2].tap do |item|
  Comment.create!(user: others[2], item: item, body: "素敵な商品ですね！")
end

# メッセージ（取引連絡）
puts "Creating messages..."

# 自分が出品者のやり取り（Logicool マウス）
Message.create!(user: me,        item: sold_item, body: "当選おめでとうございます！\nお支払いはPayPayでお願いしています。アカウント名をお知らせしますので、確認後にお振込みをお願いします。")
Message.create!(user: others[0], item: sold_item, body: "ありがとうございます！よろしくお願いします。PayPayのアカウント名を教えていただけますか？")
Message.create!(user: me,        item: sold_item, body: "PayPay: @taro_tanaka です。\nお振込みが確認できましたら発送します。よろしくお願いします！")
Message.create!(user: others[0], item: sold_item, body: "送金しました！ご確認をお願いします。")
Message.create!(user: me,        item: sold_item, body: "送金確認しました、ありがとうございます！\n本日中に発送します。追跡番号が出たらこちらでお知らせします。")
Message.create!(user: me,        item: sold_item, body: "発送しました！\n追跡番号: 123456789012\nヤマト運輸での発送です。到着まで2〜3日ほどかかる予定です。")
Message.create!(user: others[0], item: sold_item, body: "受け取りました！思っていたより状態が良くて嬉しいです。ありがとうございました！")
Message.create!(user: me,        item: sold_item, body: "喜んでいただけてよかったです！またよろしくお願いします。")

# 自分が購入者のやり取り（iPad mini）
Message.create!(user: bought_item.user, item: bought_item, body: "当選おめでとうございます！\n銀行振込でのお支払いをお願いしています。口座情報をお送りしますね。\n\n三菱UFJ銀行 渋谷支店\n普通 1234567\nヤマダ ミサキ")
Message.create!(user: me,              item: bought_item, body: "ありがとうございます！口座確認しました。本日中に振り込みます。")
Message.create!(user: bought_item.user, item: bought_item, body: "入金確認しました！ありがとうございます。\n明日発送予定です。Apple純正ケースとApple Pencilも一緒に梱包しておきますね。")
Message.create!(user: me,              item: bought_item, body: "ありがとうございます！楽しみにしています。")
Message.create!(user: bought_item.user, item: bought_item, body: "発送しました！\n追跡番号: 987654321098（佐川急便）\n明後日には届く予定です。")
Message.create!(user: me,              item: bought_item, body: "届きました！画面も綺麗でとても良い状態です。ケースとペンシルもありがとうございます。大切に使います！")
Message.create!(user: bought_item.user, item: bought_item, body: "よかったです！またよろしくお願いします😊")

# 通知（notifiable はポリモーフィックで message はモデルのメソッドで生成される）
puts "Creating notifications..."

# コメント通知（未読）
Notification.create!(user: me, notifiable: commentable_items[0].comments.last, read: false)
Notification.create!(user: me, notifiable: commentable_items[1].comments.last, read: false)

# 出品者として：抽選完了通知（既読）
Notification.create!(user: me, notifiable: sold_item, read: true)

# 出品者として：購入希望通知
Notification.create!(user: me, notifiable: my_published.entries.first, read: true)
Notification.create!(user: me, notifiable: my_published.entries.second, read: false)

# 購入者として：当選通知
Notification.create!(user: me, notifiable: Entry.find_by(user: me, status: :won), read: false)

# 購入者として：落選通知
Notification.create!(user: me, notifiable: Entry.find_by(user: me, status: :lost), read: true)

puts ""
puts "=== Seed data created! ==="
puts "Users:         #{User.count}"
puts "Items:         #{Item.count} (published: #{Item.published.count}, sold: #{Item.sold.count}, closed: #{Item.closed.count}, draft: #{Item.draft.count})"
puts "Entries:       #{Entry.count}"
puts "Watches:       #{Watch.count}"
puts "Comments:      #{Comment.count}"
puts "Messages:      #{Message.count}"
puts "Notifications: #{Notification.count} (unread: #{Notification.where(read: false).count})"
puts ""
puts "ログインユーザーは以下のアカウントでは seed データは紐づきません。"
puts "ログイン後に自分の UID を dev_001 に変更するか、seed ユーザーのデータで動作確認してください。"
