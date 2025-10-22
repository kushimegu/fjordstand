class Item < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  validates :title, :price, :payment_method, :entry_deadline_at, presence: true
  validate :image_content_type, :image_size, :image_length
  before_save :set_entry_deadline_at_end_of_day

  enum :shipping_fee_payer, { buyer: 0, seller: 1 }
  enum :status, { draft: 0, published: 1, sold: 2, closed: 3 }

  private

  def image_content_type
    return unless images.attached?

    images.each do |image|
      if !image.content_type.in?(%w[image/jpeg image/png])
        image.purge
        errors.add(:image, "のJPEGかPNGのファイルを選択してください")
      end
    end
  end

  def image_size
    return unless images.attached?

    images.each do |image|
      if image.blob.byte_size > 5.megabytes
        image.purge
        errors.add(:image, "は5MB以下のファイルをアップロードしてください")
      end
    end
  end

  def image_length
    if images.length > 5
      images.purge
      errors.add(:images, "は5枚以内にしてください")
    end
    if images.length < 1
      errors.add(:images, "を追加してください")
    end
  end

  def set_entry_deadline_at_end_of_day
    self.entry_deadline_at = entry_deadline_at.in_time_zone.end_of_day
  end
end
