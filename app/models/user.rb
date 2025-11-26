class User < ApplicationRecord
  has_many :items
  has_many :entries
  has_many :applied_items, through: :entries, source: :item

  def self.from_omniauth(auth)
    Discordrb::API::Server.resolve_member("Bot #{ENV['DISCORD_BOT_TOKEN']}", ENV["DISCORD_SERVER_ID"], auth.uid)

    user = find_or_initialize_by(uid: auth.uid)
    display_name = auth.extra.raw_info["global_name"].presence || auth.info.name
    user.update!(
      provider: auth.provider,
      name: display_name,
      avatar_url: auth.info.image
      )
      user
  end

  def entry_for(item)
    entries.find_by(item: item)
  end
end
