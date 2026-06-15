class NotifyDeadlineExtendedJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.includes(
      :applicants,
      :user,
      :first_image
    ).find(item_id)
    DiscordWebhook.new.notify_item_deadline_extended(item.applicants, item)
  end
end
