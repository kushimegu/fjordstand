require 'rails_helper'

RSpec.describe "Notifications::Reads", type: :request do
  let(:user) { create(:user) }
  let!(:notification) { create(:notification, :for_item, user: user) }
  let!(:other_notification) { create(:notification, :for_item, user: user) }

  before { login(user) }

  describe "PATCH /mark_as_read" do
    it "updates read status to true and redirect to notification link" do
      patch notification_read_path(notification)

      expect { notification.reload }.to change(notification, :read).from(false).to(true)
      expect(other_notification.reload.read).to be false
      expect(response).to redirect_to("#{notification.link}?from=notifications")
    end
  end

  describe "PATCH /mark_all_as_read" do
    it "updates all notifications status to read and redirect to notifications path" do
      patch read_all_notifications_path

      expect { notification.reload }.to change(notification, :read).from(false).to(true)
      expect { other_notification.reload }.to change(other_notification, :read).from(false).to(true)
      expect(response).to redirect_to(notifications_path)
    end
  end
end
