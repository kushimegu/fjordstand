class Item < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  validates :title, :price, :payment_method, :entry_deadline_at, presence: true, on: :publish
  validates :images, attached: { message: "を選択してください" }, on: :publish
  validates :images, limit: { max: 5 }, content_type: ['image/png', 'image/jpeg'], size: { less_than: 5.megabytes }
  before_save :set_entry_deadline_at_end_of_day

  enum :shipping_fee_payer, { buyer: 0, seller: 1 }
  enum :status, { draft: 0, published: 1, sold: 2, closed: 3 }

  private

  def set_entry_deadline_at_end_of_day
    return if entry_deadline_at.nil?

    self.entry_deadline_at = entry_deadline_at.in_time_zone.end_of_day
  end
end
