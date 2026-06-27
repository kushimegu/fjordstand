class NotifyLotterySkippedJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.includes(
      :user,
      :first_image
    ).find(item_id)

    DiscordWebhook.new.notify_lottery_skipped(item.user, item)
  end
end
