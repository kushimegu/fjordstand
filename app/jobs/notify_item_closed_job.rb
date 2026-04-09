class NotifyItemClosedJob < ApplicationJob
  queue_as :default

  def perform(item_id, reason)
    item = Item.includes(
      :user,
      { applicants: :user },
      images_attachments: :blob
    ).find(item_id)

    case reason
    when :user_action
      DiscordWebhook.new.notify_item_closed(item.applicants, item)
      item.applicants.each do |applicant|
        Notification.create!(user: applicant, notifiable: item)
      end
      DestroyEntriesJob.perform_later(item_id)
    when :no_applicants
      DiscordWebhook.new.notify_lottery_skipped(item.user, item)
      Notification.create!(user: item.user, notifiable: item)
    end
  end
end
