class RunLotteryJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = nil

    Item.transaction do
      item = Item.lock.find(item_id)
      return unless item.published?

      item.finish_sale!
    end

    if item&.saved_change_to_status?(to: "sold")
      NotifyLotteryResultsJob.perform_later(item_id)
    end
  end
end
