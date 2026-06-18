require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  let(:user) { create(:user) }
  let(:buyer) { create(:user) }

  before { login(user) }

  describe "GET /index" do
    context "when notifications exists" do
      let!(:unread_notification) { create(:notification, :for_item, user: user) }
      let!(:read_notification) { create(:notification, :for_item, :read, user: user) }
      let!(:others_notification) { create(:notification, :for_item, user: buyer) }

      it "returns current users notifications with http success" do
        get notifications_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(unread_notification.message, read_notification.message)
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
      let!(:unread_notification) { create(:notification, :for_item, user: user) }
      let!(:read_notification) { create(:notification, :for_item, :read, user: user) }

      it "returns unread notifications" do
        get notifications_path(status: "unread")

        expect(response).to have_http_status(:success)
        expect(response.body).to include(unread_notification.message)
        expect(response.body).not_to include(read_notification.message)
      end
    end

    context "when filtering by invalid status" do
      let!(:unread_notification) { create(:notification, :for_item, user: user) }
      let!(:read_notification) { create(:notification, :for_item, :read, user: user) }

      it "returns all notifications" do
        get notifications_path(status: "invalid_status")

        expect(response).to have_http_status(:success)
        expect(response.body).to include(unread_notification.message, read_notification.message)
      end
    end
  end
end
