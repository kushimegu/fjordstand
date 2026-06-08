class Notifications::ReadsController < ApplicationController
  def update
    notification = current_user.notifications.find(params[:notification_id])
    case notification.notifiable_type
    when "Comment"
      comment = notification.notifiable
      current_user.notifications
                  .unread
                  .where(notifiable_type: "Comment", notifiable_id: comment.item.comment_ids)
                  .update_all(read: true)
    when "Message"
      message = notification.notifiable
      current_user.notifications
                  .unread
                  .where(notifiable_type: "Message", notifiable_id: message.item.message_ids)
                  .update_all(read: true)
    else
      notification.update(read: true)
    end
    redirect_to url_for("#{notification.link}?from=notifications"), status: :see_other
  end

  def update_all
    current_user.notifications.unread.update_all(read: true)
    redirect_to notifications_path, notice: "全て既読にしました", status: :see_other
  end
end
