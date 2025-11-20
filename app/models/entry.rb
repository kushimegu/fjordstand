class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :item

  enum :status, { pending: 0, won: 1, lost: 2 }
end
