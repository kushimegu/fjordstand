class User < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :entries, dependent: :destroy
  has_many :applied_items, through: :entries, source: :item
  has_many :messages, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :watches, dependent: :destroy
  has_many :notifications, dependent: :destroy

  def self.from_omniauth(auth)
    begin
      Discordrb::API::Server.resolve_member("Bot #{ENV['DISCORD_BOT_TOKEN']}", ENV["DISCORD_SERVER_ID"], auth.uid)
    rescue Discordrb::Errors::UnknownMember
      return nil
    end

    guild = Discordrb::API::Server.resolve("Bot #{ENV['DISCORD_BOT_TOKEN']}", ENV["DISCORD_SERVER_ID"])
    owner_id = JSON.parse(guild)["owner_id"]

    user = find_or_initialize_by(uid: auth.uid)
    user.admin = true if auth.uid == owner_id && user.new_record?
    user.provider = auth.provider if user.provider.blank?
    user.name = auth.extra.raw_info["global_name"].presence || auth.info.name
    user.avatar_url = auth.info.image

    user.save!
    user
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
end
