require 'rails_helper'

RSpec.describe RunLotteryJob, type: :job do
  let(:seller) { create(:user) }
  let(:item) { create(:item, :published, user: seller) }
  let(:applicant) { create(:user) }

  before { ActiveJob::Base.queue_adapter = :test }

  describe '#perform' do
    it 'enqueues the job' do
      RunLotteryJob.perform_later(item.id)
      expect(RunLotteryJob).to have_been_enqueued.with(item.id)
    end

    context "when entry exists" do
      it "creates notifications to applicants and item user then enqueues NotifyLotteryResultsJob" do
        create(:entry, item: item, user: applicant)

        expect { RunLotteryJob.perform_now(item.id) }.to change { [ applicant.notifications.count, seller.notifications.count ] }.from([ 0, 0 ]).to([ 1, 1 ])
        expect(NotifyLotteryResultsJob).to have_been_enqueued.with(item.id)
      end
    end

    context "when no entry exists" do
      it "creates notification to item user and enqueues NotifyLotterySkippedJob" do
        expect { RunLotteryJob.perform_now(item.id) }.to change { seller.notifications.count }.from(0).to (1)
        expect(NotifyLotterySkippedJob).to have_been_enqueued.with(item.id)
      end
    end
  end
end
