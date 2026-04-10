class Message < ApplicationRecord
  belongs_to :user
  belongs_to :item
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :body, presence: true

  after_create_commit :create_notifications

  private

  def create_notifications
    NotifyMessageCreatedJob.perform_later(id)
  end
end
