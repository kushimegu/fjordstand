class WatchesController < ApplicationController
  # GET /watches
  def index
    @watches = current_user.watches
                            .includes(:item)
                            .order("items.entry_deadline_at DESC")
                            .page(params[:page])
                            .per(16)
  end

  # POST /watches
  def create
    @item = Item.find(params[:item_id])
    @watch = current_user.watches.build(item_id: @item.id)

    if @watch.save
      redirect_to @item, notice: "コメント欄をWatchしました"
    else
      @comment = Comment.new
      render "items/show", status: :unprocessable_content
    end
  end

  # DELETE /watches/1
  def destroy
    item = Item.find(params[:item_id])
    watch = current_user.watches.find_by(item_id: item.id)
    watch.destroy!
    redirect_to item, notice: "コメント欄のWatchを外しました", status: :see_other
  end
end
