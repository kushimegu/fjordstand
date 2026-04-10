class NotifyLotteryResultsJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.includes(
      :user,
      :winner,
      :applicants,
      { entries: :user },
      images_attachments: :blob
    ).find(item_id)

    DiscordWebhook.new.notify_lottery_completed(item.applicants + [ item.user ], item)
    now = Time.current
    notifications = item.entries.map do |entry|
      {
        user_id: entry.user_id,
        notifiable_id: entry.id,
        notifiable_type: 'Entry',
        read: false,
        created_at: now,
        updated_at: now
      }
    end
    Notification.insert_all!(notifications) if notifications.any?
    Notification.create!(user: item.user, notifiable: item)
  end
end
