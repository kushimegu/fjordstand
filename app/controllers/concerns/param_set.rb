module ParamSet
  extend ActiveSupport::Concern

  private

  def base_item_params
    [ :title, :description, :price, :shipping_fee_payer, :payment_method, :entry_deadline_at, images: [] ]
  end
end
