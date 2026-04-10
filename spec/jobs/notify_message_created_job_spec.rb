require 'rails_helper'

RSpec.describe NotifyMessageCreatedJob, type: :job do
  let!(:webhook) { stub_discord_webhook }

  let(:seller) { create(:user) }
  let(:item) { create(:item, :sold, user: seller) }
  let(:buyer) { create(:user) }
  let(:message) { create(:message, item: item, user: buyer) }

  before do
    ActiveJob::Base.queue_adapter = :test
    create(:entry, :won, item: item, user: buyer)
  end

  describe '#perform_later' do
    it 'enqueues the job' do
      expect(described_class).to have_been_enqueued.with(message.id)
    end

    it "sends webhook notification" do
      described_class.perform_now(message.id)
      expect(webhook).to have_received(:notify_new_message).with(seller, item)
    end
  end
end
