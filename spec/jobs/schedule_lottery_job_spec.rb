require 'rails_helper'

RSpec.describe ScheduleLotteryJob, type: :job do
  let(:seller) { create(:user) }
  let(:item) { create(:item, :published, user: seller, entry_deadline_at: Date.yesterday) }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe '#perform_later' do
    it 'enqueues the job' do
      described_class.perform_later
      expect(described_class).to have_been_enqueued
    end

    it "sends webhook notification" do
      described_class.perform_now
      expect { described_class.perform_now }.to have_enqueued_job(LotteryJob).with(item.id)
    end
  end
end
