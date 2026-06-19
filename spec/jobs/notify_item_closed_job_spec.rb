require 'rails_helper'

RSpec.describe NotifyItemClosedJob, type: :job do
  let!(:webhook) { stub_discord_webhook }

  let(:seller) { create(:user) }
  let(:item) { create(:item, :published, user: seller) }

  before { ActiveJob::Base.queue_adapter = :test }

  describe '#perform_later' do
    context 'when reason is :user_action' do
      let(:applicant) { create(:user) }

      before do
        create(:entry, item: item, user: applicant)
      end

      it 'enqueues the job' do
        NotifyItemClosedJob.perform_later(item.id, reason: :user_action)
        expect(NotifyItemClosedJob).to have_been_enqueued.with(item.id, reason: :user_action)
      end

      it "sends notifications" do
        expect { NotifyItemClosedJob.perform_now(item.id, reason: :user_action) }.to change { applicant.notifications.count }.from(0).to(1)
        expect(webhook).to have_received(:notify_item_closed).with([ applicant ], item)
        expect(DestroyEntriesJob).to have_been_enqueued.with(item.id)
      end
    end

    context 'when reason is :no_applicants' do
      it 'enqueues the job' do
        NotifyItemClosedJob.perform_later(item.id, reason: :no_applicants)
        expect(NotifyItemClosedJob).to have_been_enqueued.with(item.id, reason: :no_applicants)
      end

      it "sends notifications" do
        expect { NotifyItemClosedJob.perform_now(item.id, reason: :no_applicants) }.to change { seller.notifications.count }.from(0).to(1)
        expect(webhook).to have_received(:notify_lottery_skipped).with(seller, item)
      end
    end
  end
end
