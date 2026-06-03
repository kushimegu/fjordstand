class User < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :entries, dependent: :destroy
  has_many :applied_items, through: :entries, source: :item
  has_many :messages, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :watches, dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :name, presence: true

  def self.from_omniauth(auth)
    begin
      Discordrb::API::Server.resolve_member("Bot #{ENV['DISCORD_BOT_TOKEN']}", ENV["DISCORD_SERVER_ID"], auth.uid)
    rescue Discordrb::Errors::UnknownMember
      return :not_member
    end

    user = find_or_initialize_by(uid: auth.uid, provider: auth.provider)

    auth_global_name = auth.dig(:extra, :raw_info, :global_name)
    auth_name = auth.dig(:info, :name)
    incoming_name = auth_global_name.presence || auth_name.presence
    if user.new_record?
      guild = Discordrb::API::Server.resolve("Bot #{ENV['DISCORD_BOT_TOKEN']}", ENV["DISCORD_SERVER_ID"])
      owner_id = JSON.parse(guild)["owner_id"]

      user.admin = (auth.uid == owner_id)
      user.provider = auth.provider
      user.name = incoming_name || "ユーザー_#{auth.uid}"
    else
      user.name = incoming_name if incoming_name.present? && user.name != incoming_name
    end
    auth_image = auth.dig(:info, :image)
    if auth_image.present?
      new_avatar_url = URI.parse(auth_image).tap { |uri| uri.query = nil }.to_s
      user.avatar_url = new_avatar_url if user.avatar_url != new_avatar_url
    end

    if user.save
      user
    else
      nil
    end
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
