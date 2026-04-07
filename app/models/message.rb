class Message < ApplicationRecord
  belongs_to :user
  belongs_to :item
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :body, presence: true

  after_create_commit :create_notifications

  private

  def create_notifications
    ActiveSupport::Notifications.instrument("message.created", message: self)
  end
end
