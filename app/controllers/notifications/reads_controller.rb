class Notifications::ReadsController < ApplicationController
  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    if notification.notifiable_type == "Comment"
      comment = notification.notifiable
      Notification.update_all_read_by_ids!(current_user, "Comment", comment.item.comment_ids)
    else
      notification.update!(read: true)
    end
    redirect_to url_for("#{notification.link}?from=notifications"), status: :see_other
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read: true)
    redirect_to notifications_path, notice: "全て既読にしました", status: :see_other
  end
end
