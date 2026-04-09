class NotifyDeadlineExtendedJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.includes(
      applicants:
      :user,
      images_attachments: :blob
    ).find(item_id)
    DiscordWebhook.new.notify_item_deadline_extended(item.applicants, item)
  end
end
