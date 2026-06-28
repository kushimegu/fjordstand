class NotifyItemClosedJob < ApplicationJob
  queue_as :default

  def perform(item_id, applicant_ids)
    item = Item.includes(
      :user,
      :first_image
    ).find(item_id)
    applicants = User.where(id: applicant_ids)

    DiscordWebhook.new.notify_item_closed(applicants, item)
  end
end
