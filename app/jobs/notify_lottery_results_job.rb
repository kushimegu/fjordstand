class NotifyLotteryResultsJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.includes(
      :user,
      :winner,
      :applicants,
      :first_image
    ).find(item_id)

    DiscordWebhook.new.notify_lottery_completed(item.applicants + [ item.user ], item)
  end
end
