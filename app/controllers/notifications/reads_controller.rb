class Notifications::ReadsController < ApplicationController
  def update
    notification = current_user.notifications.find(params[:notification_id])
    notification.update(read: true)
    redirect_to url_for("#{notification.link}?from=notifications"), status: :see_other
  end

  def update_all
    notifications = current_user.notifications.unread
    notifications.update_all(read: true)
    redirect_to notifications_path, notice: "全て既読にしました", status: :see_other
  end
end
