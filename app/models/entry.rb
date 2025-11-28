class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :item

  enum :status, { applied: 0, won: 1, lost: 2 }

  validate :cannot_apply_for_own_item
  validate :cannot_apply_for_expired_item, on: :create

  scope :by_target, ->(target) {
  if target.present? && statuses.key?(target)
    where(status: target)
  else
    all
  end
  }

  private

  def cannot_apply_for_own_item
    if item.user_id == user_id
      errors.add(:base, "自分の出品物には応募できません")
    end
  end

  def cannot_apply_for_expired_item
    if item.entry_deadline_at < Time.current
      errors.add(:base, "締切の過ぎた商品には応募できません")
    end
  end
end
