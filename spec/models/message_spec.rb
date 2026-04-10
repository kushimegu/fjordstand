require 'rails_helper'

RSpec.describe Message, type: :model do
  let!(:webhook) { stub_discord_webhook }

  before { ActiveJob::Base.queue_adapter = :test }

  describe "#create_notifications" do
    let(:seller) { create(:user) }
    let(:buyer) { create(:user) }
    let!(:item) { create(:item, :sold, user: seller) }

    it "creates notification job" do
      create(:entry, :won, item: item, user: buyer)
      message = create(:message, item: item, user: buyer)
      expect(NotifyMessageCreatedJob).to have_been_enqueued.with(message.id)
    end
  end
end
