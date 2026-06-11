class Items::DraftsController < ApplicationController
  def create
    @item = current_user.items.build(item_params)

    if @item.save
      redirect_to listings_path, notice: "下書きとして保存しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    item = current_user.items.find(params[:id])

    item.update!(item_params)
    redirect_to listings_path, notice: "下書きを更新しました", status: :see_other
  end

  def destroy
    item = current_user.items.draft.find(params[:id])

    item.destroy!
    redirect_to listings_path, notice: "下書きを削除しました", status: :see_other
  end

  private

  def item_params
    params.expect(item: [ :title, :description, :price, :shipping_fee_payer, :payment_method, :entry_deadline_at, :status, images: [] ])
  end
end
