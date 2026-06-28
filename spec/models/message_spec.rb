require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:seller) { create(:user) }
  let(:buyer) { create(:user) }
  let!(:item) { create(:item, :sold, user: seller) }

  before do
    webhook = stub_discord_webhook

    create(:entry, :won, item: item, user: buyer)
  end

  describe "#recipient" do
    context "when sender is seller" do
      it "returns buyer" do
        message = create(:message, item: item, user: seller)
        expect(message.recipient).to eq buyer
      end
    end

    context "when sender is buyer" do
      it "returns seller" do
        message = create(:message, item: item, user: buyer)
        expect(message.recipient).to eq seller
      end
    end
  end

  describe "#create_notifications" do
    it "creates notifications and enqueues NotifyMessageCreatedJob" do
      expect { create(:message, item: item, user: buyer) }.to change { seller.notifications.count }.from(0).to(1)
      message = Message.last
      expect(NotifyMessageCreatedJob).to have_been_enqueued.with(message.id, seller.id)
    end
  end
end
