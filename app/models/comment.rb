class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :item
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :body, presence: true

  after_create_commit :add_commenter_to_watchers
  after_create_commit :notify_watchers

  private

  def add_commenter_to_watchers
    item.add_watcher(self.user)
  end

  def notify_watchers
    NotifyCommentCreatedJob.perform_later(id)
  end
end
