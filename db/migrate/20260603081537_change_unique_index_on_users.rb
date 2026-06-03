class ChangeUniqueIndexOnUsers < ActiveRecord::Migration[8.1]
  def change
    remove_index :users, name: "index_users_on_uid"

    add_index :users, [:uid, :provider], unique: true
  end
end
