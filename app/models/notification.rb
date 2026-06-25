class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read: false) }
  scope :by_target, ->(target) {
  if target == "unread"
    where(read: false)
  else
    all
  end
  }
end
