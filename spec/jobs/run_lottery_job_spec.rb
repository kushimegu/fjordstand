require 'rails_helper'

RSpec.describe RunLotteryJob, type: :job do
  let(:seller) { create(:user) }
  let(:item) { create(:item, :published, user: seller) }

  before { ActiveJob::Base.queue_adapter = :test }

  describe '#perform' do
    it 'enqueues the job' do
      RunLotteryJob.perform_later(item.id)
      expect(RunLotteryJob).to have_been_enqueued.with(item.id)
    end

    context "when entry exists" do
      it "calls Item#finish_sale! and enqueues NotifyLotteryResultsJob" do
        create(:entry, item: item, user: create(:user))

        allow(Item).to receive(:lock).and_return(Item)
        allow(Item).to receive(:find).with(item.id).and_return(item)
        allow(item).to receive(:finish_sale!)
        allow(item).to receive(:saved_change_to_status?).with(to: "sold").and_return(true)

        expect { RunLotteryJob.perform_now(item.id) }.to have_enqueued_job(NotifyLotteryResultsJob).with(item.id)
        expect(item).to have_received(:finish_sale!).once
      end
    end

    context "when no entry exists" do
      it "calls Item#finish_sale! and do not enqueue NotifyLotteryResultsJob" do
        allow(Item).to receive(:lock).and_return(Item)
        allow(Item).to receive(:find).with(item.id).and_return(item)
        allow(item).to receive(:finish_sale!)
        allow(item).to receive(:saved_change_to_status?).with(to: "sold").and_return(false)

        expect { RunLotteryJob.perform_now(item.id) }.not_to have_enqueued_job(NotifyLotteryResultsJob).with(item.id)
        expect(item).to have_received(:finish_sale!).once
      end
    end
  end
end
