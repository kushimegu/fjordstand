class Message < ApplicationRecord
  belongs_to :user
  belongs_to :item
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :body, presence: true

  after_create_commit :create_notifications

  def recipient
    return if user.admin? && [ item.user, item.winner ].exclude?(user)
    user == item.user ? item.winner : item.user
  end

  private

  def create_notifications
    NotifyMessageCreatedJob.perform_later(id)
  end
end
