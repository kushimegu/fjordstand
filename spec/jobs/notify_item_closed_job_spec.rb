require 'rails_helper'

RSpec.describe NotifyItemClosedJob, type: :job do
  let!(:webhook) { stub_discord_webhook }

  let(:item) { create(:item) }
  let(:applicant) { create(:user) }

  before { ActiveJob::Base.queue_adapter = :test }

  describe '#perform_later' do
    context 'when reason is :user_action' do
      it 'enqueues the job' do
        NotifyItemClosedJob.perform_later(item.id, applicant.id)
        expect(NotifyItemClosedJob).to have_been_enqueued.with(item.id, applicant.id)
      end

      it "sends discord notification" do
        NotifyItemClosedJob.perform_now(item.id, applicant.id)
        expect(webhook).to have_received(:notify_item_closed).with([ applicant ], item)
      end
    end
  end
end
