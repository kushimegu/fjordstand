class NotifyCommentCreatedJob < ApplicationJob
  queue_as :default

  def perform(comment_id, recipient_ids)
    comment = Comment.includes(
      item: [
        :user,
        :first_image
      ]
    ).find(comment_id)
    recipients = User.where(id: recipient_ids)

    DiscordWebhook.new.notify_new_comment(recipients, comment.item)
  end
end
