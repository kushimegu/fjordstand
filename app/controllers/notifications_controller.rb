class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications
                                  .by_target(params[:status])
                                  .order(created_at: :desc)
  end

  def read
    notification = current_user.notifications.find(params[:id])
    notification.update(read: true)
    redirect_to notification.link
  end

  def read_all
    notifications = current_user.notifications.unread
    notifications.update_all(read: true)
    redirect_to notifications_path, notice: "全て既読にしました"
  end
end
