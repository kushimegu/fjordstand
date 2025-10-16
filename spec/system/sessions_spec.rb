require 'rails_helper'
require 'webmock/rspec'

RSpec.describe "Sessions", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe 'login' do
    context 'when user is a guild member' do
      before do
        uid = '12345678890'
        OmniAuth.config.mock_auth[:discord] = OmniAuth::AuthHash.new(
          provider: 'discord',
          uid:,
          info: {
            name: 'Alice',
            image: 'https://example.com/avatar.png'
          },
          extra: {
            raw_info: {
              "global_name" => "alice"
            }
          }
        )

        WebMock.stub_request(:get, "#{Discordrb::API.api_base}/guilds/#{ENV['DISCORD_SERVER_ID']}/members/#{uid}")
        .to_return(
          status: 200,
          body: { user: { id: uid } }.to_json,
          headers: { "Content-Type" => "application/json" }
        )
      end

      it 'can login' do
        visit root_path
        click_on 'Discordでログイン'
        expect(page).to have_link, 'ログアウト'
      end
    end

    context 'when cancels authentication' do
      before do
        OmniAuth.config.mock_auth[:discord] = :invalid_credentials
      end

      it 'fails to login' do
        visit root_path
        click_on 'Discordでログイン'
        expect(page).to have_button, 'Discordでログイン'
      end
    end
  end
end
