class EntriesController < ApplicationController
  def index
    @entries = current_user.entries.includes(:item).order("items.entry_deadline_at ASC")
    @entries = @entries.where(status: params[:status]) if params[:status].present?
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
