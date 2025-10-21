class Item < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  validate :image_content_type
  validate :image_size
  before_validation :set_entry_deadline_at_end_of_day

  enum :shipping_fee_payer, { buyer: 0, seller: 1 }
  enum :status, { draft: 0, published: 1, sold: 2, closed: 3 }

  private

  def image_content_type
    return unless images.attached?

    images.each do |image|
      unless image.content_type.in?(%w[image/jpeg image/png image/gif])
        errors.add(:image, '：ファイル形式が、JPEG, PNG, GIF以外になっています。ファイル形式をご確認ください。')
      end
    end
  end

  def image_size
    return unless images.attached?

    images.each do |image|
      unless image.blob.byte_size > 1.megabytes
        errors.add(:image, '：1MB以下のファイルをアップロードしてください。')
      end
    end
  end

  def set_entry_deadline_at_end_of_day
    self.entry_deadline_at = entry_deadline_at.in_time_zone.end_of_day
  end
end
