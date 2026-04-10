class NotifyMessageCreatedJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    message = Message.includes(
      :user,
      item: [
        :user,
        :winner,
        images_attachments: :blob
      ],
    ).find(message_id)
    recipient = message.item.other_user_for(message.user)
    return if recipient.nil?
    DiscordWebhook.new.notify_new_message(recipient, message.item)
    Notification.create!(user: recipient, notifiable: message)
  end
end
