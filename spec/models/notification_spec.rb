require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:user) { create(:user) }

  describe ".unread" do
    let!(:unread_notification) { create(:notification, :for_item, user: user) }

    before { create(:notification, :for_item, :read, user: user) }

    it "returns only unread notification" do
      expect(Notification.unread).to contain_exactly(unread_notification)
    end
  end

  describe ".by_target" do
    let!(:unread_notification) { create(:notification, :for_item, user: user) }
    let!(:read_notification) { create(:notification, :for_item, :read, user: user) }

    context "when target is unread" do
      it "returns unread notifications" do
        expect(Notification.by_target("unread")).to contain_exactly(unread_notification)
      end
    end

    context "when target is invalid" do
      it "returns all notifications" do
        expect(Notification.by_target("invalid_status")).to contain_exactly(unread_notification, read_notification)
      end
    end
  end
end
