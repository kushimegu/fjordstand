require 'rails_helper'

RSpec.describe NotifyItemPublishedJob, type: :job do
  let!(:webhook) { stub_discord_webhook }

  let(:seller) { create(:user) }
  let(:item) { create(:item, user: seller) }

  before { ActiveJob::Base.queue_adapter = :test }

  describe '#perform_later' do
    it 'enqueues the job' do
      described_class.perform_later(item.id)
      expect(described_class).to have_been_enqueued.with(item.id)
    end

    it "sends webhook notification" do
      described_class.perform_now(item.id)
      expect(webhook).to have_received(:notify_item_published).with(item)
    end
  end
end
