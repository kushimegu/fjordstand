require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  let(:seller) { create(:user) }
  let(:buyer) { create(:user) }

  let!(:sold_item) { create(:item, :sold, user: seller) }
  let!(:closed_item) { create(:item, :closed, user: seller) }
  let!(:entry) { create(:entry, :won, user: buyer, item: sold_item) }

  before do
    login(seller)
  end

  describe "GET /index" do
    context "when notifications exists" do
      it "returns current users notifications with http success" do
        unread_notification = create(:notification, :for_item, user: seller, notifiable: sold_item)
        read_notification = create(:notification, :for_item, :read, user: seller, notifiable: closed_item)
        others_notification = create(:notification, :for_entry, notifiable: entry, user: buyer)

        get notifications_path
        expect(response).to have_http_status(:success)

        expect(response.body).to include(unread_notification.message)
        expect(response.body).to include(read_notification.message)
        expect(response.body).not_to include(others_notification.message)
      end
    end

    context "when no notifications exist" do
      it "returns message with http success" do
        get notifications_path
        expect(response).to have_http_status(:success)

        expect(response.body).to include("通知はありません")
      end
    end

    context "when filtering by unread status" do
      it "returns unread notifications" do
        unread_notification = create(:notification, :for_item, user: seller, notifiable: sold_item)
        read_notification = create(:notification, :for_item, :read, user: seller, notifiable: closed_item)

        get notifications_path(status: "unread")
        expect(response).to have_http_status(:success)

        expect(response.body).to include(unread_notification.message)
        expect(response.body).not_to include(read_notification.message)
      end
    end

    context "when filtering by invalid status" do
      it "returns all notifications" do
        unread_notification = create(:notification, :for_item, user: seller, notifiable: sold_item)
        read_notification = create(:notification, :for_item, :read, user: seller, notifiable: closed_item)

        get notifications_path(status: "invalid_status")
        expect(response).to have_http_status(:success)

        expect(response.body).to include(unread_notification.message)
        expect(response.body).to include(read_notification.message)
      end
    end
  end

  describe "PATCH /read" do
    it "updates read status to true and redirect to notification link" do
      unread_notification_1 = create(:notification, :for_item, user: seller, notifiable: sold_item)
      unread_notification_2 = create(:notification, :for_item, user: seller, notifiable: closed_item)

      expect(unread_notification_1.read).to be false
      expect(unread_notification_2.read).to be false
      patch read_notification_path(unread_notification_1)

      expect(unread_notification_1.reload.read).to be true
      expect(unread_notification_2.reload.read).to be false
      expect(response).to redirect_to(unread_notification_1.link)
    end
  end

  describe "PATCH /read_all" do
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
