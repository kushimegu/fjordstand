module LoginSupport
  module Request
    def login(user)
      stub_discord_oauth(user)
      get "/auth/discord/callback"
      follow_redirect!
    end
  end

  module System
    def login(user)
      stub_discord_oauth(user)
      visit root_path
      click_on 'Discordでログイン'
    end
  end

  def stub_discord_oauth(user)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:discord] = OmniAuth::AuthHash.new(
      provider: 'discord',
      uid: user.uid,
      info: {
        name: user.name,
        image: user.avatar_url
      },
      extra: {
        raw_info: {
          "global_name" => nil
        }
      }
    )
    WebMock.stub_request(:get, "#{Discordrb::API.api_base}/guilds/#{ENV['DISCORD_SERVER_ID']}/members/#{user.uid}")
    .to_return(
      status: 200,
      body: { user: { id: user.uid } }.to_json,
      headers: { "Content-Type" => "application/json" }
      )
  end
end
