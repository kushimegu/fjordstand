class ItemsController < ApplicationController
  before_action :set_user_item_with_images, only: %i[edit update]
  before_action :ensure_item_editable, only: %i[edit update]
  before_action :require_admin, only: %i[destroy]

  PER_PAGE = 20

  # GET /items
  def index
    @items = Item.published
                  .not_expired
                  .order(entry_deadline_at: :asc, created_at: :asc)
                  .includes(:user, :winner, first_image_attachment: { blob: :variant_records })
                  .page(params[:page])
                  .per(PER_PAGE)
  end

  # GET /items/1
  def show
    @item = Item.includes(ordered_image_attachments: { blob: :variant_records }).find(params[:id])
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
    @item = current_user.items.build(item_create_params)

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
    @item.assign_attributes(item_update_params)

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

    item.destroy!
    redirect_to items_path, notice: "商品を削除しました", status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user_item_with_images
    @item = current_user.items.includes(ordered_image_attachments: { blob: :variant_records }).find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def item_create_params
    params.expect(item: [ *Item::FIELDS_FOR_DRAFT ])
  end

  def item_update_params
    if @item.draft?
      params.expect(item: [ *Item::FIELDS_FOR_DRAFT ])
    else
      params.expect(item: [ *Item::FIELDS_FOR_PUBLISHED ])
    end
  end

  def ensure_item_editable
    redirect_to @item, alert: "締切を過ぎた商品は編集できません" unless @item.editable?
  end

  def require_admin
    redirect_to items_path, alert: "削除する権限がありません" unless current_user.admin?
  end
end
