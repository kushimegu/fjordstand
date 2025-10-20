module LoginSupport
  def login(user)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:discord] = discord_mock(user)
    WebMock.stub_request(:get, "#{Discordrb::API.api_base}/guilds/#{ENV['DISCORD_SERVER_ID']}/members/#{user.uid}")
    .to_return(
      status: 200,
      body: { user: { id: user.uid } }.to_json,
      headers: { "Content-Type" => "application/json" }
    )
    get "/auth/discord/callback"
    follow_redirect!
  end

  def discord_mock(user)
    OmniAuth::AuthHash.new(
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
  end
end
