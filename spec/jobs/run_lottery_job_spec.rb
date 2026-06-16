require 'rails_helper'

RSpec.describe RunLotteryJob, type: :job do
  let(:seller) { create(:user) }
  let(:item) { create(:item, :published, user: seller) }

  before { ActiveJob::Base.queue_adapter = :test }

  describe '#perform_later' do
    it 'enqueues the job' do
      RunLotteryJob.perform_later(item.id)
      expect(RunLotteryJob).to have_been_enqueued.with(item.id)
    end

    it "calls Lottery#run" do
      lottery_double = instance_double(Lottery)
      allow(Lottery).to receive(:new).with(item).and_return(lottery_double)
      allow(lottery_double).to receive(:run)

      RunLotteryJob.perform_now(item.id)
      expect(Lottery).to have_received(:new).with(instance_of(Item))
      expect(lottery_double).to have_received(:run)
    end

    it 'enqueues NotifyLotteryResultsJob' do
      create(:entry, item: item, user: create(:user))

      expect { RunLotteryJob.perform_now(item.id) }.to have_enqueued_job(NotifyLotteryResultsJob).with(item.id)
    end
  end
end
