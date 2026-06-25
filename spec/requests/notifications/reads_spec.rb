require 'rails_helper'

RSpec.describe "Notifications::Reads", type: :request do
  let(:user) { create(:user) }
  let!(:notification) { create(:notification, :for_item, user: user) }
  let!(:other_notification) { create(:notification, :for_item, user: user) }

  before { login(user) }

  describe "PATCH /mark_as_read" do
    it "updates read status to true and redirect to notification link" do
      patch mark_as_read_notification_path(notification)

      expect { notification.reload }.to change(notification, :read).from(false).to(true)
      expect(other_notification.reload.read).to be false

      strategy = NotificationsHelper::Strategy.build_strategy(notification)
      expect(response).to redirect_to("#{strategy.redirect_path}?from=notifications")
    end
  end

  describe "PATCH /mark_all_as_read" do
    it "updates all notifications status to read and redirect to notifications path" do
      patch mark_all_as_read_notifications_path

      expect { notification.reload }.to change(notification, :read).from(false).to(true)
      expect { other_notification.reload }.to change(other_notification, :read).from(false).to(true)
      expect(response).to redirect_to(notifications_path)
    end
  end
end
