require 'rails_helper'

RSpec.describe ScheduleLotteryJob, type: :job do
  let(:seller) { create(:user) }
  let(:item) { create(:item, :published, user: seller, entry_deadline_at: Date.yesterday) }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe '#perform_later' do
    it 'enqueues the job' do
      ScheduleLotteryJob.perform_later
      expect(ScheduleLotteryJob).to have_been_enqueued
    end

    it "sends webhook notification" do
      ScheduleLotteryJob.perform_now
      expect { ScheduleLotteryJob.perform_now }.to have_enqueued_job(RunLotteryJob).with(item.id)
    end
  end
end
