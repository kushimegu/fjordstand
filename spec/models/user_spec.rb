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
      WebMock.stub_request(:get, "#{Discordrb::API.api_base}/guilds/#{ENV['DISCORD_SERVER_ID']}")
      .to_return(
        status: 200,
        body: { "owner_id": "123" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
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

  describe "#entry_for" do
    let(:user) { create(:user) }
    let(:item) { create(:item) }
    let!(:entry) { create(:entry, user: user, item: item) }

    context "when entry for item exists" do
      it "returns entry" do
        expect(user.entry_for(item)).to eq(entry)
      end
    end

    context "when no entry for item exists" do
      let(:other_item) { create(:item) }

      it "returns nil" do
        expect(user.entry_for(other_item)).to be_nil
      end
    end
  end

  describe "#watch_comment_of" do
    let(:user) { create(:user) }
    let(:item) { create(:item) }

    context "when user watch comment of item" do
      let!(:watch) { create(:watch, user: user, item: item) }

      it "returns watch" do
        expect(user.watch_comment_of(item)).to eq(watch)
      end
    end

    context "when user does not watch comment of item" do
      it "returns nil" do
        expect(user.watch_comment_of(item)).to be_nil
      end
    end
  end

  describe "#has_unread_notifications?" do
    let(:user) { create(:user) }

    context "when user has unread notifications" do
      it "returns true" do
        create(:notification, :for_item, user: user)
        expect(user.has_unread_notifications?).to be(true)
      end
    end

    context "when user has no unread notifications" do
      it "returns false" do
        create(:notification, :for_item, :read, user: user)
        expect(user.has_unread_notifications?).to be(false)
      end
    end
  end

  describe "#has_unread_messages?" do
    let(:user) { create(:user) }

    context "when user has unread message" do
      it "returns true" do
        create(:notification, :for_message, user: user)
        expect(user.has_unread_messages?).to be(true)
      end
    end

    context "when user has no unread messages" do
      it "returns false" do
        create(:notification, :for_message, :read, user: user)
        expect(user.has_unread_messages?).to be(false)
      end
    end
  end

  describe "#unread_message_items_count" do
    let(:user) { create(:user) }
    let(:item) { create(:item) }
    let(:other_item) { create(:item) }

    before do
      message1a = create(:message, item: item)
      message1b = create(:message, item: item)
      create(:notification, user: user, notifiable: message1a)
      create(:notification, user: user, notifiable: message1b)

      message2 = create(:message, item: other_item)
      create(:notification, user: user, notifiable: message2)

      read_message = create(:message, item: item)
      create(:notification, user: user, notifiable: read_message)

      create(:notification, :for_item, user: user)
    end

    it "returns item count with unread messages" do
      expect(user.unread_message_items_count).to eq(2)
    end
  end
end
