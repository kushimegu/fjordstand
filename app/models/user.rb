class User < ApplicationRecord
  def self.from_omniauth(auth)
    user = find_or_initialize_by(uid: auth.uid)
    display_name = auth.extra.raw_info["global_name"].presence || auth.info.name
    user.update!(
      provider: auth.provider,
      name: display_name,
      avatar_url: auth.info.image
      )
      user
  end
end
