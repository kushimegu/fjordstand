require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:seller) { create(:user) }
  let(:buyer) { create(:user) }
  let!(:item) { create(:item, :sold, user: seller) }

  before do
    ActiveJob::Base.queue_adapter = :test
    webhook = stub_discord_webhook

    create(:entry, :won, item: item, user: buyer)
  end

  describe "#recipient" do
    context "when sender is admin and is seller" do
      it "returns buyer" do
        seller.update!(admin: true)
        message = create(:message, item: item, user: seller)

        expect(message.recipient).to eq buyer
      end
    end

    context "when sender is admin and is buyer" do
      it "returns seller" do
        buyer.update!(admin: true)
        message = create(:message, item: item, user: buyer)

        expect(message.recipient).to eq seller
      end
    end

    context "when sender is admin and is not seller or buyer" do
      it "returns nil" do
        admin = create(:user, admin: true)
        message = create(:message, item: item, user: admin)

        expect(message.recipient).to be_nil
      end
    end

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
    it "creates notification job" do
      message = create(:message, item: item, user: buyer)
      expect(NotifyMessageCreatedJob).to have_been_enqueued.with(message.id)
    end
  end
end
