class ChangeColumnNullItems < ActiveRecord::Migration[8.0]
  def change
    change_column_null :items, :title, true
    change_column_null :items, :price, true
    change_column_null :items, :shipping_fee_payer, true
    change_column_null :items, :entry_deadline_at, true
  end
end
