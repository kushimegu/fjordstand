class User < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :entries, dependent: :destroy
  has_many :applied_items, through: :entries, source: :item
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
    display_name = auth.extra.raw_info["global_name"].presence || auth.info.name
    user.update!(
      provider: auth.provider,
      name: display_name,
      avatar_url: auth.info.image,
      admin: owner_id == auth.uid
      )
    user
  end

  def entry_for(item)
    entries.find_by(item_id: item.id)
  end

  def watch_comment_of(item)
    watches.find_by(item_id: item.id)
  end
end
