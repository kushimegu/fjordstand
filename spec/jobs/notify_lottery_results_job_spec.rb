require 'rails_helper'

RSpec.describe NotifyLotteryResultsJob, type: :job do
  let!(:webhook) { stub_discord_webhook }

  let(:seller) { create(:user) }
  let(:item) { create(:item, :sold, user: seller) }
  let(:winner) { create(:user) }
  let!(:entry) { create(:entry, :won, item: item, user: winner) }

  before { ActiveJob::Base.queue_adapter = :test }

  describe '#perform_later' do
    it 'enqueues the job' do
      NotifyLotteryResultsJob.perform_later(item.id)
      expect(NotifyLotteryResultsJob).to have_been_enqueued.with(item.id)
    end

    it "creates notifications" do
      expect { NotifyLotteryResultsJob.perform_now(item.id) }.to change(Notification, :count).from(0).to(2)
      expect(seller.notifications.last.notifiable.id).to eq(item.id)
      expect(winner.notifications.last.notifiable.id).to eq(entry.id)
      expect(webhook).to have_received(:notify_lottery_completed).with([ winner, seller ], item)
    end
  end
end
