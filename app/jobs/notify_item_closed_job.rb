class NotifyItemClosedJob < ApplicationJob
  queue_as :default

  def perform(item_id, reason:)
    item = Item.includes(
      :user,
      :applicants,
      images_attachments: :blob
    ).find(item_id)

    case reason
    when :user_action
      DiscordWebhook.new.notify_item_closed(item.applicants, item)
      now = Time.current
      notifications = item.applicants.map do |applicant|
        {
          user_id: applicant.id,
          notifiable_id: item.id,
          notifiable_type: "Item",
          read: false,
          created_at: now,
          updated_at: now
        }
      end
      Notification.insert_all!(notifications) if notifications.any?
      DestroyEntriesJob.perform_later(item_id)
    when :no_applicants
      DiscordWebhook.new.notify_lottery_skipped(item.user, item)
      Notification.create!(user: item.user, notifiable: item)
    end
  end
end
