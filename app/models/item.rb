class Item < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  has_many :ordered_image_attachments, -> { order(id: :asc) }, as: :record, class_name: "ActiveStorage::Attachment"
  has_many :ordered_images, through: :ordered_image_attachments, source: :blob
  has_one :first_image_attachment, -> { order(id: :asc) }, as: :record, class_name: "ActiveStorage::Attachment"
  has_one :first_image, through: :first_image_attachment, source: :blob
  has_many :entries, dependent: :destroy
  has_many :applicants, through: :entries, source: :user
  has_one :won_entry, -> { where(status: :won) }, class_name: "Entry", inverse_of: false
  has_one :winner, through: :won_entry, source: :user
  has_many :messages, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :watches, dependent: :destroy
  has_many :watchers, through: :watches, source: :user
  has_many :notifications, as: :notifiable, dependent: :destroy

  enum :shipping_fee_payer, { buyer: 0, seller: 1 }
  enum :status, { draft: 0, published: 1, sold: 2, closed: 3 }

  attr_accessor :title_append, :description_append, :payment_method_append

  MAX_COUNT = 5
  ALLOWED_TYPES = %w[ image/png image/jpeg ].freeze
  MAX_SIZE_MB = 5

  validates :images, limit: { max: MAX_COUNT }, content_type: ALLOWED_TYPES, size: { less_than: MAX_SIZE_MB.megabytes }

  validates :title, length: { maximum: 255 }, presence: true, on: :publish
  validates :description, length: { maximum: 1000 }, on: :publish
  validates :price, presence: true, on: :publish
  validates :shipping_fee_payer, presence: { message: "を選択してください" }, on: :publish
  validates :payment_method, length: { maximum: 255 }, presence: { message: "を選択してください" }, on: :publish
  validates :entry_deadline_at, presence: true, on: :publish
  validates :images, attached: { message: "を1枚以上選択してください" }, on: :publish
  validate :combined_title_must_be_within_limit, on: :publish
  validate :combined_description_must_be_within_limit, on: :publish
  validate :combined_payment_method_must_be_within_limit, on: :publish
  validate :deadline_must_be_today_or_later, on: :publish
  validate :price_cannot_be_changed_after_published, on: :publish
  validate :deadline_cannot_be_changed_earlier_after_published, on: :publish

  before_save :append_additional_contents
  before_save :set_entry_deadline_at_end_of_day, if: :will_save_change_to_entry_deadline_at?

  after_save_commit :comment_watch_by_seller, if: -> { saved_change_to_attribute?(:status, to: "published") }
  after_save_commit :notify_publishing, if: -> { saved_change_to_attribute?(:status, to: "published") }
  after_update_commit :notify_deadline_extension, if: :saved_only_change_deadline?

  scope :not_expired, -> { where(entry_deadline_at: Time.current.beginning_of_day..) }
  scope :expired, -> { where.not(id: not_expired).where(status: :published) }
  scope :commentable, -> { where.not(status: :draft) }

  FIELDS_FOR_DRAFT = [ :title, :description, :price, :shipping_fee_payer, :payment_method, :entry_deadline_at, images: [] ].freeze
  FIELDS_FOR_PUBLISHED = (FIELDS_FOR_DRAFT - [ :title, :description, :payment_method ]).freeze

  def close!(reason: :user_action)
    update!(status: :closed)
    NotifyItemClosedJob.perform_later(id, reason: reason)
  end

  def editable?
    return false if published? && entry_deadline_at < Time.current
    return false if sold?
    true
  end

  def commentable?
    !draft?
  end

  def participant?(user)
    user && user.id.in?([ user_id, won_entry&.user_id ])
  end

  private

  def combined_title_must_be_within_limit
    if title_append.present? && [ title, title_append ].join(" ").length > 255
      errors.add(:title, "は合わせて255文字以内で入力してください")
    end
  end

  def combined_description_must_be_within_limit
    if description_append.present? && [ description, description_append ].compact.join("\n").length > 255
      errors.add(:description, "は合わせて1000文字以内で入力してください")
    end
  end

  def combined_payment_method_must_be_within_limit
    if payment_method_append.present? && [ payment_method, payment_method_append ].join(" ").length > 255
      errors.add(:payment_method, "は合わせて255文字以内で入力してください")
    end
  end

  def deadline_must_be_today_or_later
    return if entry_deadline_at.nil? || entry_deadline_at.to_date >= Date.current

    errors.add(:entry_deadline_at, "は本日以降に設定してください")
  end

  def price_cannot_be_changed_after_published
    if status_was == "published" && will_save_change_to_price?
      errors.add(:price, "は出品後に変更できません")
    end
  end

  def deadline_cannot_be_changed_earlier_after_published
    if status_was == "published" && will_save_change_to_entry_deadline_at?
      new_deadline = entry_deadline_at.to_date
      old_deadline = entry_deadline_at_was.to_date

      if new_deadline < old_deadline
        errors.add(:entry_deadline_at, "は元の締切日以降に設定してください")
      end
    end
  end

  def append_additional_contents
    if title_append.present? && !title&.include?(title_append)
      self.title = [ title, title_append ].join(" ")
    end

    if description_append.present? && !description&.include?(description_append)
      self.description = [ description, description_append ].compact.join("\n")
    end

    if payment_method_append.present? && !payment_method&.include?(payment_method_append)
      self.payment_method = [ payment_method, payment_method_append ].join(" ")
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
    NotifyItemPublishedJob.perform_later(id)
  end

  def notify_deadline_extension
    NotifyDeadlineExtendedJob.perform_later(id)
  end

  def saved_only_change_deadline?
    !saved_change_to_status? && saved_change_to_entry_deadline_at?
  end
end
