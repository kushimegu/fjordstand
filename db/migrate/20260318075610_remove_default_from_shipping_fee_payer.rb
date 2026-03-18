class RemoveDefaultFromShippingFeePayer < ActiveRecord::Migration[8.1]
  def change
    change_column_default :items, :shipping_fee_payer, nil
  end
end
