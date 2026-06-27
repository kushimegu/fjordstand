class RunLotteryJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    Item.finish_sale!(item_id)
  end
end
