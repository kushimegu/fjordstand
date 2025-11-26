class EntriesController < ApplicationController
  def index
    @items = current_user.applied_items
  end

  # POST /entries
  def create
    @item = Item.find(params[:item_id])
    @entry = current_user.entries.build(item_id: @item.id)

    if @entry.save
      redirect_to @item, notice: "購入希望を申請しました"
    else
      render "items/show", status: :unprocessable_content
    end
  end

  # DELETE /entries/1
  def destroy
    item = Item.find(params[:item_id])
    entry = current_user.entries.find_by(item_id: item.id)
    entry.destroy!
    redirect_to item, notice: "購入希望を取り消しました", status: :see_other
  end
end
