require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  let(:seller) { create(:user, uid: "1234567890") }
  let(:buyer) { create(:user, uid: "1234567891") }

  let!(:sold_item) { create(:item, user: seller, status: :sold) }
  let!(:closed_item) { create(:item, user: seller, status: :closed)}
  let!(:entry) { create(:entry, user: buyer, item: sold_item, status: :won) }

  before do
    login(seller)
  end

  describe "GET /index" do
    context "when notifications exists" do
      let!(:unread_notification) { create(:notification, :for_item, user: seller, notifiable: sold_item, read: false)}
      let!(:read_notification) { create(:notification, :for_item, user: seller, notifiable: closed_item, read: true)}
      let!(:other_notification) { create(:notification, :for_entry, notifiable: entry, user: buyer)}
    
      it "returns current users notifications with http success" do
        get notifications_path
        expect(response).to have_http_status(:success)

        expect(response.body).to include(unread_notification.message)
        expect(response.body).to include(read_notification.message)
        expect(response.body).to_not include(other_notification.message)
      end
    end

    context "when no notifications exist" do
      it "returns empty array with http success" do
        get notifications_path
        expect(response).to have_http_status(:success)

        expect(response.body).to include("通知はありません")
      end
    end
  
    context "when filtering by status" do
      let!(:unread_notification) { create(:notification, :for_item, user: seller, notifiable: sold_item, read: false)}
      let!(:read_notification) { create(:notification, :for_item, user: seller, notifiable: closed_item, read: true)}

      context "when status is unread" do
        it "returns unread notifications" do
          get notifications_path(status: "unread")
          expect(response).to have_http_status(:success)

          expect(response.body).to include(unread_notification.message)
          expect(response.body).to_not include(read_notification.message)
        end
      end

      context "when status is invalid" do
        it "returns all notifications" do
          get notifications_path(status: "invalid_status")

          expect(response).to have_http_status(:success)

          expect(response.body).to include(unread_notification.message)
          expect(response.body).to include(read_notification.message)
        end
      end
    end
  end

  describe "GET /read" do
    let!(:unread_notification1) { create(:notification, :for_item, user: seller, notifiable: sold_item, read: false)}
    let!(:unread_notification2) { create(:notification, :for_item, user: seller, notifiable: closed_item, read: false)}

    it "updates read status to true and redirect to notification link" do
      expect(unread_notification1.read).to be false
      expect(unread_notification2.read).to be false
      get read_notification_path(unread_notification1)

      expect(unread_notification1.reload.read).to be true
      expect(unread_notification2.reload.read).to be false
      expect(response).to redirect_to(unread_notification1.link)
    end
  end

  describe "GET /read_all" do
    let!(:unread_notification1) { create(:notification, :for_item, user: seller, notifiable: sold_item, read: false)}
    let!(:unread_notification2) { create(:notification, :for_item, user: seller, notifiable: closed_item, read: false)}
    
    it "updates all notifications status to read and redirect to notifications path" do
      expect(unread_notification1.read).to be false
      expect(unread_notification2.read).to be false
      get read_all_notifications_path

      expect(unread_notification1.reload.read).to be true
      expect(unread_notification2.reload.read).to be true
      expect(response).to redirect_to(notifications_path)
    end
  end
end
