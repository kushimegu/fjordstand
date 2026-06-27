class NotifyMessageCreatedJob < ApplicationJob
  queue_as :default

  def perform(message_id, recipient_id)
    message = Message.includes(item: :first_image).find(message_id)
    recipient = User.find(recipient_id)

    DiscordWebhook.new.notify_new_message(recipient, message.item)
  end
end
