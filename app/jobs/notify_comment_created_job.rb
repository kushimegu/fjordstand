class NotifyCommentCreatedJob < ApplicationJob
  queue_as :default

  def perform(comment_id)
    comment = Comment.includes(
      item: [
        :user,
        :watchers,
        images_attachments: :blob
      ]
    ).find(comment_id)
    recipients = comment.item.watchers.where.not(id: comment.user_id)
    return if recipients.empty?
    DiscordWebhook.new.notify_new_comment(recipients, comment.item)
    now = Time.current
    notifications = recipients.map do |recipient|
      {
        user_id: recipient.id,
        notifiable_id: comment.id,
        notifiable_type: 'Comment',
        read: false,
        created_at: now,
        updated_at: now
      }
    end
    Notification.insert_all!(notifications) if notifications.any?
  end
end
