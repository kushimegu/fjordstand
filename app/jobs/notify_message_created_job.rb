class NotifyMessageCreatedJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    message = Message.includes(
      :user,
      item: [
        :user,
        :winner,
        :first_image
      ],
    ).find(message_id)
    recipient = message.recipient
    return if recipient.nil?
    recipient.notifications.create!(notifiable: message)
    DiscordWebhook.new.notify_new_message(recipient, message.item)
  end
end
