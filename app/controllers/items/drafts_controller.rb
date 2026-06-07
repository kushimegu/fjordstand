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
    item = current_user.items.includes(ordered_image_attachments: :blob).find(params[:id])

    if item.update(item_params)
      redirect_to listings_path, notice: "下書きを更新しました", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    item = current_user.items.find(params[:id])
    raise ActiveRecord::RecordNotFound unless item.deletable_by?(current_user)

    item.destroy
    redirect_to listings_path, notice: "下書きを削除しました", status: :see_other
  end

  private

  def item_params
    params.expect(item: [ :title, :title_append, :description, :description_append, :price, :shipping_fee_payer, :payment_method, :payment_method_append, :entry_deadline_at, :status, images: [] ])
  end
end
