class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :item
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :body, presence: true

  after_create_commit :add_commentator_to_watchers
  after_create_commit :notify_watchers

  private

  def add_commentator_to_watchers
    return if item.watchers.exists?(user_id)

    item.watchers << self.user
  end

  def notify_watchers
    DiscordWebhook.new.notify_new_comment(item.watchers.without(self.user), item)
    item.watchers.each do |watcher|
      next if self.user_id == watcher.id
      Notification.create!(user: watcher, notifiable: self)
    end
  end
end
