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
end
