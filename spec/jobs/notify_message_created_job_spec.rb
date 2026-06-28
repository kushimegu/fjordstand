require 'rails_helper'

RSpec.describe NotifyMessageCreatedJob, type: :job do
  let!(:webhook) { stub_discord_webhook }

  let(:seller) { create(:user) }
  let(:item) { create(:item, :sold, user: seller) }
  let(:buyer) { create(:user) }

  before do
    create(:entry, :won, item: item, user: buyer)
  end

  describe '#perform_later' do
    it 'enqueues the job' do
      message = build(:message, item: item, user: buyer)
      message.save!
      expect(NotifyMessageCreatedJob).to have_been_enqueued.with(message.id, seller.id)
    end

    it "sends discord notification" do
      message = create(:message, item: item, user: buyer)
      NotifyMessageCreatedJob.perform_now(message.id, seller.id)
      expect(webhook).to have_received(:notify_new_message).with(seller, item)
    end
  end
end
