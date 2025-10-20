class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :price, null: false
      t.integer :shipping_fee_payer, null: false, default: 0
      t.string :payment_method
      t.datetime :entry_deadline_at, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
