class Comment < ApplicationRecord

  belongs_to :user
  belongs_to :item
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :body, presence: true

  after_create_commit :notify_seller

  private

  def notify_seller
    return if self.user_id == item.user_id
    Notification.create!(user: item.user, notifiable: self)
  end
end
