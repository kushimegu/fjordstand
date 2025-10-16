require 'rails_helper'

RSpec.describe "Sessions", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe '#callback' do
    before do
      OmniAuth.config.mock_auth[:discord] = OmniAuth::AuthHash.new(
        provider: 'discord',
        uid: '1234567890',
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
    end

    it 'can login with omniauth-discord' do
      visit root_path
      click_on 'Discordでログイン'
      expect(page).to have_link, 'ログアウト'
    end
  end

  describe '#failure' do
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
