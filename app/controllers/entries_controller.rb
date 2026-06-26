class EntriesController < ApplicationController
  before_action :set_item, only: %i[create destroy]

  PER_PAGE = 12

  def index
    @entries = current_user.entries
                            .by_target(params[:status])
                            .order("items.entry_deadline_at DESC, entries.created_at DESC")
                            .includes(item: [ :user, :winner, first_image_attachment: { blob: :variant_records } ])
                            .page(params[:page])
                            .per(PER_PAGE)
  end

  # POST /entries
  def create
    @entry = current_user.entries.build(item_id: @item.id)

    if @entry.save
      redirect_to @item, notice: "購入希望を申請しました"
    else
      render "items/show", status: :unprocessable_content
    end
  end

  # DELETE /entries/1
  def destroy
    entry = current_user.entries.find_by(item_id: @item.id)

    if entry&.destroy!
      flash[:notice] = "購入希望を取り消しました"
    end
    redirect_to @item, status: :see_other
  end

  private

  def set_item
    @item = Item.published.find(params[:item_id])
  end
end
