class RunLotteryJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.find(item_id)
    item.finish_sale!
  end
end
