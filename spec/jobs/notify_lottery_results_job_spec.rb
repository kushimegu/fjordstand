require 'rails_helper'

RSpec.describe NotifyLotteryResultsJob, type: :job do
  let!(:webhook) { stub_discord_webhook }

  let(:seller) { create(:user) }
  let(:item) { create(:item, :sold, user: seller) }
  let(:winner) { create(:user) }

  before do
    create(:entry, :won, item: item, user: winner)
  end

  describe '#perform_later' do
    it "sends discord notification" do
      NotifyLotteryResultsJob.perform_now(item.id)
      expect(webhook).to have_received(:notify_lottery_completed).with([ winner, seller ], item)
    end
  end
end
