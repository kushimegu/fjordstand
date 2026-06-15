class NotifyItemPublishedJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.includes(
      :user,
      :first_image
    ).find(item_id)
    DiscordWebhook.new.notify_item_published(item)
  end
end
