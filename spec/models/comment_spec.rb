require 'rails_helper'

RSpec.describe Comment, type: :model do
  before do
    webhook = stub_discord_webhook
  end

  describe "#add_commentator_to_watchers" do
    let(:item) { create(:item, :published) }
    let(:user) { create(:user) }

    it "adds commentator to watchers" do
      comment = build(:comment, item: item, user: user)

      expect { comment.save! }.to change { item.watchers.count }.by(1)
      expect(item.watchers).to include(user)
    end
  end

  describe "#notify_watchers" do
    let(:seller) { create(:user) }
    let(:item) { create(:item, :published, user: seller) }
    let(:commenter) { create(:user) }

    it "sends notification to watchers except commenter" do
      expect { create(:comment, user: commenter, item: item) }.to change { seller.notifications.count }.by(1)
      comment = Comment.last
      expect(NotifyCommentCreatedJob).to have_been_enqueued.with(comment.id, [ seller.id ])
    end
  end
end
