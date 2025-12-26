class AddUniqueIndexToEntriesUserIdAndItemId < ActiveRecord::Migration[8.0]
  def change
    add_index :entries, [:user_id, :item_id], unique: true
  end
end
