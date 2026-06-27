require 'rails_helper'

RSpec.describe Message, type: :model do
  before do
    ActiveJob::Base.queue_adapter = :test
    webhook = stub_discord_webhook
  end

  describe "#create_notifications" do
    let(:seller) { create(:user) }
    let(:buyer) { create(:user) }
    let!(:item) { create(:item, :sold, user: seller) }

    before { create(:entry, :won, item: item, user: buyer) }

    it "creates notifications and enqueues NotifyMessageCreatedJob" do
      expect { create(:message, item: item, user: buyer) }.to change { seller.notifications.count }.from(0).to(1)
      message = Message.last
      expect(NotifyMessageCreatedJob).to have_been_enqueued.with(message.id, seller.id)
    end
  end
end
