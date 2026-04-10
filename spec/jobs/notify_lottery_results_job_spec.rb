require 'rails_helper'

RSpec.describe NotifyLotteryResultsJob, type: :job do
    let!(:webhook) { stub_discord_webhook }

  let(:seller) { create(:user) }
  let(:item) { create(:item, :sold, user: seller) }
  let(:winner) { create(:user) }

  before do
    ActiveJob::Base.queue_adapter = :test
    create(:entry, :won, item: item, user: winner)
  end

  describe '#perform_later' do
    it 'enqueues the job' do
      described_class.perform_later(item.id)
      expect(described_class).to have_been_enqueued.with(item.id)
    end

    it "sends webhook notification" do
      described_class.perform_now(item.id)
      expect(webhook).to have_received(:notify_lottery_completed).with(match_array([winner, seller]), item)
    end
  end
end
