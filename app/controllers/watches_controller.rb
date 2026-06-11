class WatchesController < ApplicationController
  before_action :set_item, only: %i[create destroy]

  # GET /watches
  def index
    @watches = current_user.watches
                            .order("items.entry_deadline_at DESC, watches.created_at DESC")
                            .includes(item: [ :user, :winner, first_image_attachment: { blob: :variant_records } ])
                            .page(params[:page])
                            .per(16)
  end

  # POST /watches
  def create
    @watch = current_user.watches.build(item_id: @item.id)

    if @watch.save
      redirect_to @item, notice: "コメント欄をWatchしました"
    else
      render "items/show", status: :unprocessable_content
    end
  end

  # DELETE /watches/1
  def destroy
    watch = current_user.watches.find_by!(item_id: @item.id)

    watch.destroy!
    redirect_to @item, notice: "コメント欄のWatchを外しました", status: :see_other
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end
end
