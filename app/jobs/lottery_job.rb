class LotteryJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.find(item_id)

    Lottery.new(item).run
    NotifyLotteryResultsJob.perform_later(item_id)
  end
end
