class NotifyItemPublishedJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.includes(
      :user,
      images_attachments: :blob
    ).find(item_id)
    DiscordWebhook.new.notify_item_published(item)
  end
end
