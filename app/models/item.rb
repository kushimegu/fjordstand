class Item < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  has_many :entries, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  enum :shipping_fee_payer, { buyer: 0, seller: 1 }
  enum :status, { draft: 0, published: 1, sold: 2, closed: 3 }

  attr_accessor :title_append, :description_append, :payment_method_append

  validates :title, length: { maximum: 255 }, presence: true, on: :publish
  validates :price, presence: true, on: :publish
  validates :payment_method, presence: true, on: :publish
  validates :entry_deadline_at, presence: true, on: :publish
  validates :images, attached: { message: "を1枚以上選択してください" }, on: :publish
  validates :images, limit: { max: 5 }, content_type: [ "image/png", "image/jpeg" ], size: { less_than: 5.megabytes }

  before_save :set_entry_deadline_at_end_of_day

  validate :price_not_change_after_published, on: :publish
  validate :deadline_today_or_later, on: :publish
  validate :deadline_not_change_earlier_after_published, on: :publish

  scope :expired, -> { where("entry_deadline_at < ?", Time.current).where(status: :published) }
  scope :by_target, ->(target) {
  if target.present? && statuses.key?(target)
    where(status: target)
  else
    all
  end
  }

  def other_user_for(current_user)
    seller = user
    winner = entries.find_by(status: :won).user
    [seller, winner].find{ |user| user != current_user }
  end

  private

  def set_entry_deadline_at_end_of_day
    return if entry_deadline_at.nil?

    self.entry_deadline_at = entry_deadline_at.in_time_zone.end_of_day
  end

  def price_not_change_after_published
    if status_was == "published" && will_save_change_to_price?
      errors.add(:price, "は出品後に変更できません")
    end
  end

  def deadline_today_or_later
    return if entry_deadline_at.nil? || entry_deadline_at.to_date >= Date.current

    errors.add(:entry_deadline_at, "は本日以降に設定してください")
  end

  def deadline_not_change_earlier_after_published
    if status_was == "published" && will_save_change_to_entry_deadline_at?
      new_deadline = entry_deadline_at.to_date
      old_deadline = entry_deadline_at_was.to_date

      if new_deadline < old_deadline
        errors.add(:entry_deadline_at, "は元の締切日以降に設定してください")
      end
    end
  end
end
