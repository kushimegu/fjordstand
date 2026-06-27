class RunLotteryJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item, sold = Item.finish_sale!(item_id)

    if sold
      now = Time.current
      notifications = item.entries.map do |entry|
        {
          user_id: entry.user_id,
          notifiable_id: entry.id,
          notifiable_type: "Entry",
          read: false,
          created_at: now,
          updated_at: now
        }
      end
      ActiveRecord::Base.transaction do
        Notification.insert_all!(notifications) if notifications.any?
        item.notifications.create!(user: item.user)
      end
      NotifyLotteryResultsJob.perform_later(item.id)
    else
      item.notifications.create!(user: item.user)
      NotifyLotterySkippedJob.perform_later(item.id)
    end
  end
end
