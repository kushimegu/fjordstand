class Items::ClosesController < ApplicationController
  def update
    item = current_user.items.find(params[:item_id])
    item.close(reason: :user_action)
    redirect_to listings_path, notice: "商品を取り下げました", status: :see_other
  end
end
