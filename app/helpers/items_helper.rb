module ItemsHelper
  def shipping_fee_class(payer)
    case payer
    when "seller"
      "text-red-400"
    else
      "text-gray-600"
    end
  end
end
