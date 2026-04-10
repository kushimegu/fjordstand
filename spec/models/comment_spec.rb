require 'rails_helper'

RSpec.describe Comment, type: :model do
  before do
    ActiveJob::Base.queue_adapter = :test
    webhook = stub_discord_webhook
  end

  describe "validations" do
    context "when body is blank" do
      let(:comment) { build(:comment, body: nil) }

      it "is invalid" do
        is_valid = comment.valid?

        expect(is_valid).to be false
        expect(comment.errors[:body]).to include("を入力してください")
      end
    end
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
    let(:commentator) { create(:user) }
    let(:watcher) { create(:user) }

    it "sends notification to watchers except commentator" do
      create(:watch, item: item, user: watcher)
      comment = create(:comment, user: commentator, item: item)
      expect(item.watchers.count).to eq(3)

      expect(NotifyCommentCreatedJob).to have_been_enqueued.with(comment.id)
    end
  end
end
