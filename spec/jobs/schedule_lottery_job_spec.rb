require 'rails_helper'

RSpec.describe ScheduleLotteryJob, type: :job do
  let(:seller) { create(:user) }
  let!(:expired_item) { create(:item, :published, user: seller, entry_deadline_at: Date.yesterday) }
  let!(:unexpired_item) { create(:item, :published, user: seller, entry_deadline_at: Date.tomorrow) }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe '#perform_later' do
    it 'enqueues the job' do
      ScheduleLotteryJob.perform_later
      expect(ScheduleLotteryJob).to have_been_enqueued
    end

    it "enqueue RunLotteryJob for expired item" do
      ScheduleLotteryJob.perform_now
      expect(RunLotteryJob).to have_been_enqueued.with(expired_item.id)
      expect(RunLotteryJob).not_to have_been_enqueued.with(unexpired_item.id)
    end
  end
end
