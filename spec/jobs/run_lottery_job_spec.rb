require 'rails_helper'

RSpec.describe RunLotteryJob, type: :job do
  let(:item) { create(:item, :published) }

  describe '#perform' do
    it "calls Item#finish_sale!" do
      allow(Item).to receive(:find).with(item.id).and_return(item)
      allow(item).to receive(:finish_sale!)
      RunLotteryJob.perform_now(item.id)
      expect(item).to have_received(:finish_sale!).once
    end
  end
end
