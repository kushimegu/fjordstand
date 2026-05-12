require 'rails_helper'

RSpec.describe "Notifications::Reads", type: :request do
  let(:seller) { create(:user) }
  let(:sold_item) { create(:item, :sold, user: seller) }
  let(:closed_item) { create(:item, :closed, user: seller) }

  before { login(seller) }

  describe "PATCH /update" do
    it "updates read status to true and redirect to notification link" do
      unread_notification_1 = create(:notification, :for_item, user: seller, notifiable: sold_item)
      unread_notification_2 = create(:notification, :for_item, user: seller, notifiable: closed_item)

      expect(unread_notification_1.read).to be false
      expect(unread_notification_2.read).to be false
      patch notification_read_path(unread_notification_1)

      expect(unread_notification_1.reload.read).to be true
      expect(unread_notification_2.reload.read).to be false
      expect(response).to redirect_to(unread_notification_1.link)
    end
  end

  describe "PATCH /update_all" do
    it "updates all notifications status to read and redirect to notifications path" do
      unread_notification_1 = create(:notification, :for_item, user: seller, notifiable: sold_item)
      unread_notification_2 = create(:notification, :for_item, user: seller, notifiable: closed_item)

      expect(unread_notification_1.read).to be false
      expect(unread_notification_2.read).to be false
      patch read_all_notifications_path

      expect(unread_notification_1.reload.read).to be true
      expect(unread_notification_2.reload.read).to be true
      expect(response).to redirect_to(notifications_path)
    end
  end
end
