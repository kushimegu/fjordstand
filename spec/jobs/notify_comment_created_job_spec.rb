require 'rails_helper'

RSpec.describe NotifyCommentCreatedJob, type: :job do
  let!(:webhook) { stub_discord_webhook }

  let(:seller) { create(:user) }
  let(:item) { create(:item, :published, user: seller) }
  let(:commenter) { create(:user) }
  let(:comment) { create(:comment, item: item, user: commenter) }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe '#perform_later' do
    it 'enqueues the job' do
      expect(described_class).to have_been_enqueued.with(comment.id)
    end

    it "sends webhook notification" do
      described_class.perform_now(comment.id)
      expect(webhook).to have_received(:notify_new_comment).with(contain_exactly([ seller ]), item)
    end
  end
end
