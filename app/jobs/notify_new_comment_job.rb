class NotifyNewCommentJob < ApplicationJob
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
    next if recipients.empty?
    DiscordWebhook.new.notify_new_comment(recipients, comment.item)
    recipients.each do |recipient|
      Notification.create!(user: recipient, notifiable: comment)
    end
  end
end
