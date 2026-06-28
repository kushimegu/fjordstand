require 'rails_helper'

RSpec.describe RunLotteryJob, type: :job do
  let(:item) { create(:item, :published) }

  before { ActiveJob::Base.queue_adapter = :test }

  describe '#perform' do
    it 'enqueues the job' do
      RunLotteryJob.perform_later(item.id)
      expect(RunLotteryJob).to have_been_enqueued.with(item.id)
    end

    it "calls Item#finish_sale!" do
      allow(Item).to receive(:find).with(item.id).and_return(item)
      expect(item).to receive(:finish_sale!)
      RunLotteryJob.perform_now(item.id)
    end
  end
end
