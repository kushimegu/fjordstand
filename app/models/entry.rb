class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :item

  enum :status, { applied: 0, won: 1, lost: 2 }

  validate :cannot_apply_to_own_item

  private

  def cannot_apply_to_own_item
    if item.user_id == user_id
      errors.add(:base, "自分の出品物には応募できません")
    end
  end
end
