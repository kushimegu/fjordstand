class Notifications::ReadsController < ApplicationController
  def mark_as_read
    notification = current_user.notifications.find(params[:id])

    if notification.notifiable_type == "Comment"
      comment = notification.notifiable
      current_user.mark_notifications_as_read!("Comment", comment.item.comment_ids)
    else
      notification.update!(read: true)
    end
    redirect_path = helpers.resolve_redirect_path(notification)
    redirect_to url_for("#{redirect_path}?from=notifications"), status: :see_other
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read: true)
    redirect_to notifications_path, notice: "全て既読にしました", status: :see_other
  end
end
