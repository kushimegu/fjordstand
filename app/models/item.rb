class Item < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  validates :title, :price, :payment_method, :entry_deadline_at, presence: true, on: :publish
  validates :images, attached: { message: "を選択してください" }, on: :publish
  validates :images, limit: { max: 5 }, content_type: [ "image/png", "image/jpeg" ], size: { less_than: 5.megabytes }
  before_save :set_entry_deadline_at_end_of_day
  validate :price_not_change_when_published, :deadline_later_than_today, :deadline_later_than_original_when_published

  enum :shipping_fee_payer, { buyer: 0, seller: 1 }
  enum :status, { draft: 0, published: 1, sold: 2, closed: 3 }

  attr_accessor :title_append, :description_append, :payment_method_append

  private

  def set_entry_deadline_at_end_of_day
    return if entry_deadline_at.nil?

    self.entry_deadline_at = entry_deadline_at.in_time_zone.end_of_day
  end

  def price_not_change_when_published
    if published? && will_save_change_to_price?
      errors.add(:price, "は出品後に変更できません")
    end
  end

  def deadline_later_than_today
    return if entry_deadline_at.present? && entry_deadline_at.to_date >= Date.current
    
    errors.add(:entry_deadline_at, "は本日以降に設定してください")
  end

  def deadline_later_than_original_when_published
    if will_save_change_to_entry_deadline_at?
      new_deadline = entry_deadline_at
      old_deadline = entry_deadline_at_was

      if published? && new_deadline < old_deadline
        error.add(:entry_deadline_at, "は元の締切日以降に設定してください")
      end
    end
  end
end
