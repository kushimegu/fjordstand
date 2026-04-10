require "discordrb/webhooks"

class DiscordWebhook
  include Rails.application.routes.url_helpers

  def initialize
    @client = Discordrb::Webhooks::Client.new(url: ENV["WEBHOOK_URL"])
  end

  def notify_item_published(item)
    send_webhook("🛒新しい商品が出品されました！", item, use_image: true)
  end

  def notify_item_closed(users, item)
    mentions = create_mentions(users)
    prefix = create_prefix(mentions)
    send_webhook("#{prefix}📢出品が取り下げられました", item, use_image: false)
  end

  def notify_item_deadline_extended(users, item)
    mentions = create_mentions(users)
    prefix = create_prefix(mentions)
    send_webhook("#{prefix}⏰購入希望申込期限が延長されました", item, use_image: false)
  end

  def notify_lottery_completed(users, item)
    mentions = create_mentions(users)
    prefix = create_prefix(mentions)
    send_webhook("#{prefix}🎉抽選が完了し#{item.winner.name}さんが当選しました！", item, use_image: false)
  end

  def notify_lottery_skipped(users, item)
    mentions = create_mentions(users)
    prefix = create_prefix(mentions)
    send_webhook("#{prefix}⏭️希望者がいなかったため当選者なしで公開終了しました", item, use_image: false)
  end

  def notify_new_comment(users, item)
    mentions = create_mentions(users)
    prefix = create_prefix(mentions)
    send_webhook("#{prefix}📝新しいコメントがつきました", item, use_image: false)
  end

  def notify_new_message(users, item)
    mentions = create_mentions(users)
    prefix = create_prefix(mentions)
    send_webhook("#{prefix}💬新しいメッセージが届きました", item, use_image: false)
  end

  private

  def create_prefix(mentions)
    return "" if mentions.blank?

    mentions + "\n"
  end

  def create_mentions(users)
    Array.wrap(users).map { |user| "<@#{user.uid}>" }.join(" ")
  end

  def send_webhook(content, item, use_image: false)
    @client.execute do |builder|
      builder.content = content
      builder.add_embed { |embed| build_item_embed(embed, item, use_image: use_image) }
    end
  end

  def build_item_embed(embed, item, use_image: false)
    embed.title = item.title
    embed.url = item_url(item)
    embed.description = item.description.to_s
    embed.add_field(name: "価格", value: "#{item.price}円", inline: true)
    embed.add_field(name: "送料負担", value: "#{I18n.t("enums.item.shipping_fee_payer.#{item.shipping_fee_payer}")}", inline: true)
    embed.add_field(name: "お支払い方法", value: "#{item.payment_method}", inline: true)
    embed.add_field(name: "購入希望申込期限", value: "#{I18n.l(item.entry_deadline_at, format: :default)}", inline: false)

    image_url = url_for(item.images.first)
    if use_image
      embed.image = Discordrb::Webhooks::EmbedImage.new(url: image_url)
      embed.thumbnail = nil
    else
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: image_url)
      embed.image = nil
    end

    embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "出品者: #{item.user.name}", icon_url: "#{item.user.avatar_url.presence || "default-avatar.png"}")
  end
end
