require 'rails_helper'

RSpec.describe Message, type: :model do
  describe "#create_notifications" do
    let(:seller) { create(:user) }
    let(:buyer) { create(:user) }
    let!(:item) { create(:item, :with_max_five_images, :sold, user: seller) }

    context "when sender is seller" do
      it "creates notification to buyer" do
        create(:entry, :won, item: item, user: buyer)
        expect { create(:message, item: item, user: seller) }.to change { buyer.notifications.count }.by(1)
      end
    end

    context "when sender is buyer" do
      it "creates notification to seller" do
        create(:entry, :won, item: item, user: buyer)
        expect { create(:message, item: item, user: buyer) }.to change { seller.notifications.count }.by(1)
      end
    end
  end
end
