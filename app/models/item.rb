class Item < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  has_many :entries, dependent: :destroy
  has_many :applicants, through: :entries, source: :user
  has_one :winning_entry, -> { where(status: :won) }, class_name: "Entry"
  has_one :winner, through: :winning_entry, source: :user
  has_many :messages, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :watches, dependent: :destroy
  has_many :watchers, through: :watches, source: :user
  has_many :notifications, as: :notifiable, dependent: :destroy

  enum :shipping_fee_payer, { buyer: 0, seller: 1 }
  enum :status, { draft: 0, published: 1, sold: 2, closed: 3 }

  attr_accessor :title_append, :description_append, :payment_method_append

  validates :images, limit: { max: 5 }, content_type: [ "image/png", "image/jpeg" ], size: { less_than: 5.megabytes }

  validates :title, length: { maximum: 255 }, presence: true, on: :publish
  validates :price, presence: true, on: :publish
  validates :payment_method, presence: { message: "を選択してください" }, on: :publish
  validates :entry_deadline_at, presence: true, on: :publish
  validates :images, attached: { message: "を1枚以上選択してください" }, on: :publish
  validate :deadline_today_or_later, on: :publish
  validate :price_not_change_after_published, on: :publish
  validate :deadline_not_change_earlier_after_published, on: :publish

  before_save :set_entry_deadline_at_end_of_day

  after_create_commit :comment_watch_by_seller
  after_save_commit :notify_publishing, if: -> { saved_change_to_attribute?(:status, to: :published) }
  after_update_commit :notify_deadline_extension, if: :saved_only_change_deadline?

  scope :expired, -> { where("entry_deadline_at < ?", Time.current).where(status: :published) }
  scope :by_target, ->(target) {
  if target.present? && statuses.key?(target)
    where(status: target)
  else
    all
  end
  }

  def other_user_for(current_user)
    seller = user
    [ seller, winner ].find { |user| user != current_user }
  end

  def close!(by:)
    update!(status: :closed)
    notify_close(by)
    entries.destroy_all
  end

  private

  def deadline_today_or_later
    return if entry_deadline_at.nil? || entry_deadline_at.to_date >= Date.current

    errors.add(:entry_deadline_at, "は本日以降に設定してください")
  end

  def price_not_change_after_published
    if status_was == "published" && will_save_change_to_price?
      errors.add(:price, "は出品後に変更できません")
    end
  end

  def deadline_not_change_earlier_after_published
    if status_was == "published" && will_save_change_to_entry_deadline_at?
      new_deadline = entry_deadline_at.to_date
      old_deadline = entry_deadline_at_was.to_date

      if new_deadline < old_deadline
        errors.add(:entry_deadline_at, "は元の締切日以降に設定してください")
      end
    end
  end

  def set_entry_deadline_at_end_of_day
    return if entry_deadline_at.nil?

    self.entry_deadline_at = entry_deadline_at.in_time_zone.end_of_day
  end

  def comment_watch_by_seller
    return if watchers.exists?(user.id)

    watchers << user
  end

  def notify_publishing
    DiscordWebhook.new.notify_item_published(self)
  end

  def notify_deadline_extension
    DiscordWebhook.new.notify_item_deadline_extended(applicants, self)
  end

  def saved_only_change_deadline?
    return if saved_change_to_attribute?(:status, to: :published)

    saved_change_to_attribute?(:entry_deadline_at)
  end

  def notify_close(closed_by)
    case closed_by
    when :user
      applicants.each do |applicant|
        Notification.create!(user: applicant, notifiable: self)
      end
      DiscordWebhook.new.notify_item_closed(applicants, self)
    when :lottery
      Notification.create!(user: user, notifiable: self)
      DiscordWebhook.new.notify_lottery_skipped(self.user, self)
    end
  end
end
