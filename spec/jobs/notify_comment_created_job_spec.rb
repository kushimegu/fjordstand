require 'rails_helper'

RSpec.describe NotifyCommentCreatedJob, type: :job do
  let!(:webhook) { stub_discord_webhook }

  let(:seller) { create(:user) }
  let(:item) { create(:item, :published, user: seller) }
  let(:watcher) { create(:user) }
  let(:comment) { create(:comment, item: item) }

  before do
    ActiveJob::Base.queue_adapter = :test

    create(:watch, user: watcher, item: item)
    comment
  end

  describe '#perform_later' do
    it 'enqueues the job' do
      expect(NotifyCommentCreatedJob).to have_been_enqueued.with(comment.id)
    end

    it "creates notifications" do
      expect { NotifyCommentCreatedJob.perform_now(comment.id) }.to change(Notification, :count).by(2)
      expect(webhook).to have_received(:notify_new_comment).with(contain_exactly(watcher, seller), item)
    end
  end
end
