class RunLotteryJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    Item.transaction do
      item = Item.lock.find(item_id)
      return unless item.published?

      Lottery.new(item).run
      NotifyLotteryResultsJob.perform_later(item_id)
    end
  end
end
