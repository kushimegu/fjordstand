class Item < ApplicationRecord
  belongs_to :user

  before_validation :set_entry_deadline_at_end_of_day

  enum :shipping_fee_payer, { buyer: 0, seller: 1 }
  enum :status, { draft: 0, published: 1, sold: 2, closed: 3 }

  private

  def set_entry_deadline_at_end_of_day
    self.entry_deadline_at = entry_deadline_at.in_time_zone.end_of_day
  end
end
