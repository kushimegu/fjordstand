class User < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :sold_items, -> { where(status: :sold) }, class_name: "Item"
  has_many :entries, dependent: :destroy
  has_many :applied_items, through: :entries, source: :item
  has_many :won_entries, -> { where(status: :won) }, class_name: "Entry"
  has_many :won_items, through: :won_entries, source: :item
  has_many :messages, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :watches, dependent: :destroy
  has_many :notifications, dependent: :destroy

  def self.from_omniauth(auth)
    guild_info = Discordrb::API::Server.resolve("Bot #{ENV['DISCORD_BOT_TOKEN']}", ENV["DISCORD_SERVER_ID"])
    owner_id = JSON.parse(guild_info)["owner_id"]

    begin
      Discordrb::API::Server.resolve_member("Bot #{ENV['DISCORD_BOT_TOKEN']}", ENV["DISCORD_SERVER_ID"], auth.uid)
    rescue Discordrb::Errors::UnknownMember
      return nil
    end

    user = find_or_initialize_by(uid: auth.uid)
    user.update!(
      provider: auth.provider,
      name: auth.extra.raw_info["global_name"].presence || auth.info.name,
      avatar_url: auth.info.image,
      admin: (owner_id == auth.uid) || (auth.uid == "850718521234948146")
      )
    user
  end

  def dealing_items
    Item.where(id: sold_items).or(Item.where(id: won_items))
  end

  def applying_item_ids_for(items)
    entries.applied.where(item_id: items.map(&:id)).pluck(:item_id).to_set
  end

  def watching_item_ids_for(items)
    watches.where(item_id: items.map(&:id)).pluck(:item_id).to_set
  end

  def entry_for(item)
    entries.find_by(item_id: item.id)
  end

  def watch_comment_of(item)
    watches.find_by(item_id: item.id)
  end

  def has_unread_notifications?
    notifications.unread.exists?
  end

  def has_unread_messages?
    notifications.unread.where(notifiable_type: "Message").exists?
  end

  def has_unread_messages_for?(item)
    notifications.unread.exists?(notifiable_type: "Message", notifiable_id: item.message_ids)
  end

  def mark_notifications_as_read!(notifiable_type:, notifiable_ids:)
    notifications.unread.where(notifiable_type:, notifiable_id: notifiable_ids).update_all(read: true)
  end
end
