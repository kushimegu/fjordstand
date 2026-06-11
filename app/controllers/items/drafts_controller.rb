class Items::DraftsController < ApplicationController
  before_action :set_item, only: %i[update destroy]

  def create
    @item = current_user.items.build(item_params)

    if @item.save
      redirect_to listings_path, notice: "下書きとして保存しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @item.update!(item_params)
    redirect_to listings_path, notice: "下書きを更新しました", status: :see_other
  end

  def destroy
    @item.destroy!
    redirect_to listings_path, notice: "下書きを削除しました", status: :see_other
  end

  private

  def set_item
    @item = current_user.items.draft.find(params[:id])
  end

  def item_params
    params.expect(item: [ :title, :description, :price, :shipping_fee_payer, :payment_method, :entry_deadline_at, :status, images: [] ])
  end
end
