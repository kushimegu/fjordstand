class NotifyLotteryResultsJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.includes(
      :user,
      :winner,
      { applicants: :user },
      { entries: :user },
      images_attachments: :blob
    ).find(item_id)

    DiscordWebhook.new.notify_lottery_completed(item.applicants + [ item.user ], item)
    item.entries.each do |entry|
      Notification.create!(user: entry.user, notifiable: entry)
    end
    Notification.create!(user: item.user, notifiable: item)
  end
end
