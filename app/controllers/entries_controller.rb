class EntriesController < ApplicationController
  # POST /entries
  def create
    item = Item.find(params[:item_id])
    entry = current_user.entries.build(item_id: item.id)
    entry.save
    redirect_to item, notice: "購入希望を申請しました"
  end

  # DELETE /entries/1
  def destroy
    item = Item.find(params[:item_id])
    entry = current_user.entries.find_by(item_id: item.id)
    entry.destroy!
    redirect_to item, notice: "購入希望を取り消しました", status: :see_other
  end
end
