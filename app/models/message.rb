class Message < ApplicationRecord
  belongs_to :user
  belongs_to :item
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :body, presence: true

  after_create_commit :create_notifications

  def recipient
    user == item.user ? item.winner : item.user
  end

  private

  def create_notifications
    recipient_id = message.item.other_user_for(message.user).id
    return if recipient_id.nil?
    message.notifications.create!(user_id: recipient_id)
    NotifyMessageCreatedJob.perform_later(id, recipient_id)
  end
end
