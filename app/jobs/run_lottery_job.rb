class RunLotteryJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    Item.transaction do
      item = Item.lock.find(item_id)
      return unless item.published?

      Lottery.new(item).run
      if item.applicants.any?
        NotifyLotteryResultsJob.perform_later(item_id)
      else
        NotifyItemClosedJob.perform_later(item_id, reason: :no_applicants)
      end
    end
  end
end
