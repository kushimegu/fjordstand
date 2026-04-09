class DestroyEntriesJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.find(item_id)
    item.entries.destroy_all
  end
end
