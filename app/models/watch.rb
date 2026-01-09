class Watch < ApplicationRecord
  belongs_to :user
  belongs_to :item

  validates :user_id, uniqueness: { scope: :item_id, message: "はこのコメント欄をすでにWatchしています" }
end
