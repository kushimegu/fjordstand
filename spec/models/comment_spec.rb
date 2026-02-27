require 'rails_helper'

RSpec.describe Comment, type: :model do
  before do
    webhook_double = instance_double(DiscordWebhook, notify_item_published: true, notify_new_comment: true)
    allow(DiscordWebhook).to receive(:new).and_return(webhook_double)
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
    let(:item) { create(:item, :with_max_five_images, :published) }
    let(:user) { create(:user) }

    it "adds commentator to watchers" do
      comment = build(:comment, item: item, user: user)

      expect { comment.save! }.to change { item.watchers.count }.by(1)
      expect(item.watchers).to include(user)
    end
  end

  describe "#notify_watchers" do
    let(:seller) { create(:user) }
    let(:item) { create(:item, :with_max_five_images, :published, user: seller) }
    let(:commentator) { create(:user) }
    let(:watcher) { create(:user) }

    it "sends notification to watchers except commentator" do
      create(:watch, item: item, user: watcher)
      comment = build(:comment, user: commentator, item: item)

      expect { comment.save! }.to change(Notification, :count).by(2)
      expect(item.watchers.count).to eq(3)

      notified_users = Notification.where(notifiable: comment).pluck(:user_id)
      expect(notified_users).to contain_exactly(seller.id, watcher.id)
    end
  end
end
