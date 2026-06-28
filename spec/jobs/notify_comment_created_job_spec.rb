require 'rails_helper'

RSpec.describe NotifyCommentCreatedJob, type: :job do
  let!(:webhook) { stub_discord_webhook }

  let(:seller) { create(:user) }
  let(:item) { create(:item, :published, user: seller) }
  let(:watcher) { create(:user) }

  before do
    create(:watch, user: watcher, item: item)
  end

  describe '#perform_later' do
    it 'enqueues the job' do
      comment = build(:comment, item: item)
      comment.save!
      expect(NotifyCommentCreatedJob).to have_been_enqueued.with(comment.id, contain_exactly(watcher.id, seller.id))
    end

    it "sends discord notification" do
      comment = create(:comment, item: item)
      NotifyCommentCreatedJob.perform_now(comment.id, [ seller.id, watcher.id ])
      expect(webhook).to have_received(:notify_new_comment).with(contain_exactly(watcher, seller), item)
    end
  end
end
