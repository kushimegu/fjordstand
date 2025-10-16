require 'rails_helper'
require 'webmock/rspec'

RSpec.describe User, type: :model do
  describe '.from_omniauth' do
    let(:uid) { '1234567890' }
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: 'discord',
        uid:,
        info: {
          name: 'Bob',
          image: 'https://example.com/avatar.png'
        },
        extra: {
          raw_info: {
            "global_name" => "bobbi"
          }
        }
      )
    end
    let(:user) { described_class.from_omniauth(auth) }

    before do
      WebMock.stub_request(:get, "#{Discordrb::API.api_base}/guilds/#{ENV['DISCORD_SERVER_ID']}/members/#{uid}")
      .to_return(
        status: 200,
        body: { user: { id: uid } }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    end

    context 'when the user already exists' do
      let!(:existing_user) { create(:user, uid: '1234567890', name: 'Carol') }

      it 'returns the existing user' do
        expect(user).to eq(existing_user)
      end

      it 'updates user information' do
        expect(user.name).to eq('bobbi')
      end
    end

    context 'when the user is new' do
      it 'increases user count by 1' do
        expect { described_class.from_omniauth(auth) }.to change(described_class, :count).by(1)
      end

      it 'creates user' do
        expect(user).to have_attributes(provider: 'discord', uid: '1234567890', name: 'bobbi', avatar_url: 'https://example.com/avatar.png')
      end
    end
  end
end
