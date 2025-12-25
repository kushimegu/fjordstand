require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe "validations" do
    context "when body is blank" do
      let(:comment) { build(:comment, body: nil) }

      it "is invalid" do
        is_valid = comment.valid?

        expect(is_valid).to eq false
        expect(comment.errors[:body]).to include("を入力してください")
      end
    end
  end

  describe "#notify_seller" do
    let(:seller) { create(:user) }
    let(:item) { create(:item, user: seller, status: :published) }
    let(:other_user) { create(:user) }

    context "when commentator is not seller" do
      it "sends notification to seller" do
        comment = build(:comment, user: other_user, item: item)

        expect{ comment.save! }.to change{ seller.notifications.count }.by(1)

        notification = Notification.last
        expect(notification.user).to eq(seller)
        expect(notification.notifiable).to eq(comment)
      end
    end

    context "when commentator is seller" do
      it "does not send notification to seller" do
        comment = build(:comment, user: seller, item: item)

        expect{ comment.save! }.not_to change{ seller.notifications.count }
      end
    end
  end
end
