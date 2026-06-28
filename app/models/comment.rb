class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :item
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :body, presence: true

  after_create_commit :add_commenter_to_watchers
  after_create_commit :notify_watchers

  private

  def add_commenter_to_watchers
    item.add_watcher(user)
  end

  def notify_watchers
    recipient_ids = item.watchers.where.not(id: user_id).pluck(:id)
    return if recipient_ids.empty?

    now = Time.current
    notifications = recipient_ids.map do |recipient_id|
      {
        user_id: recipient_id,
        notifiable_id: id,
        notifiable_type: self.class.name,
        read: false,
        created_at: now,
        updated_at: now
      }
    end
    Notification.insert_all!(notifications)
    NotifyCommentCreatedJob.perform_later(id, recipient_ids)
  end
end
