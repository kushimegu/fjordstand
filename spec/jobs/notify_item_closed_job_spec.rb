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
        described_class.perform_later(item.id, reason: :user_action)
        expect(described_class).to have_been_enqueued.with(item.id, reason: :user_action)
      end

      it "sends notifications" do
        expect { described_class.perform_now(item.id, reason: :user_action) }.to have_enqueued_job(DestroyEntriesJob).with(item.id)
        expect(webhook).to have_received(:notify_item_closed).with(contain_exactly([ applicant ]), item)
        expect(Notification.where(user: applicant, notifiable: item)).to exist
      end
    end

    context 'when reason is :no_applicants' do
      it 'enqueues the job' do
        described_class.perform_later(item.id, reason: :no_applicants)
        expect(described_class).to have_been_enqueued.with(item.id, reason: :no_applicants)
      end

      it "sends notifications" do
        described_class.perform_now(item.id, reason: :no_applicants)
        expect(webhook).to have_received(:notify_lottery_skipped).with(seller, item)
        expect(Notification.where(user: seller, notifiable: item)).to exist
      end
    end
  end
end
