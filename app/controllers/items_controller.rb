class ItemsController < ApplicationController
  before_action :set_user_item_with_images, only: %i[edit update]
  before_action :ensure_item_editable, only: %i[edit update]

  # GET /items
  def index
    @items = Item.published
                  .not_expired
                  .order(entry_deadline_at: :asc, created_at: :asc)
                  .includes(:user, :winner, first_image_attachment: :blob)
                  .page(params[:page])
                  .per(20)
  end

  # GET /items/1
  def show
    @item = Item.includes(ordered_image_attachments: :blob).find(params[:id])
  end

  # GET /items/new
  def new
    @item = current_user.items.build
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  def create
    @item = current_user.items.build(item_params)

    if @item.valid?(:publish)
      @item.status = :published
      @item.save!
      redirect_to @item, notice: "商品を出品しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /items/1
  def update
    @item.assign_attributes(item_params)
    title_append = params[:item][:title_append]
    description_append = params[:item][:description_append]
    payment_method_append = params[:item][:payment_method_append]

    @item.title = [ @item.title, title_append ].join(" ") if title_append.present?
    @item.description = [ @item.description.presence, description_append ].compact.join("\n") if description_append.present?
    @item.payment_method = [ @item.payment_method, payment_method_append ].join(" ") if payment_method_append.present?

    if @item.valid?(:publish)
      @item.status = :published
      @item.save!
      notice_key = @item.saved_change_to_status? ? :publish : :update
      redirect_to @item, notice: t("notices.item.#{notice_key}"), status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /items/1
  def destroy
    item = Item.find(params[:id])
    raise ActiveRecord::RecordNotFound unless item.deletable_by?(current_user)

    item.destroy
    redirect_to items_path, notice: "商品を削除しました", status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user_item_with_images
    @item = current_user.items.includes(ordered_image_attachments: :blob).find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def item_params
    params.expect(item: [ :title, :title_append, :description, :description_append, :price, :shipping_fee_payer, :payment_method, :payment_method_append, :entry_deadline_at, :status, images: [] ])
  end

  def ensure_item_editable
    return if @item.editable?
    redirect_to @item, alert: "締切を過ぎた商品は編集できません"
  end
end
