require 'rails_helper'

RSpec.describe "Notifications::Reads", type: :request do
  let(:seller) { create(:user) }
  let(:sold_item) { create(:item, :sold, user: seller) }
  let(:closed_item) { create(:item, :closed, user: seller) }

  before { login(seller) }

  describe "PATCH /mark_as_read" do
    it "updates read status to true and redirect to notification link" do
      unread_notification_1 = create(:notification, :for_item, user: seller, notifiable: sold_item)
      unread_notification_2 = create(:notification, :for_item, user: seller, notifiable: closed_item)

      expect(unread_notification_1.read).to be false
      expect(unread_notification_2.read).to be false
      patch mark_as_read_notification_path(unread_notification_1)

      expect(unread_notification_1.reload.read).to be true
      expect(unread_notification_2.reload.read).to be false
      expect(response).to redirect_to("#{unread_notification_1.link}?from=notifications")
    end
  end

  describe "PATCH /mark_all_as_read" do
    it "updates all notifications status to read and redirect to notifications path" do
      unread_notification_1 = create(:notification, :for_item, user: seller, notifiable: sold_item)
      unread_notification_2 = create(:notification, :for_item, user: seller, notifiable: closed_item)

      expect(unread_notification_1.read).to be false
      expect(unread_notification_2.read).to be false
      patch mark_all_as_read_notifications_path

      expect(unread_notification_1.reload.read).to be true
      expect(unread_notification_2.reload.read).to be true
      expect(response).to redirect_to(notifications_path)
    end
  end
end
