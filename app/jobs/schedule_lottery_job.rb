class ScheduleLotteryJob < ApplicationJob
  queue_as :default

  def perform
    Item.expired.pluck(:id).each do |item_id|
      RunLotteryJob.perform_later(item_id)
    end
  end
end
