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

    it "calls Item#finish_sale!" do
      allow(Item).to receive(:finish_sale!)
      RunLotteryJob.perform_now(item.id)
      expect(Item).to have_received(:finish_sale!).with(item.id).once
    end
  end
end
