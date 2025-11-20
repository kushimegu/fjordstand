class ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit update destroy]
  before_action :ensure_user, only: %i[edit update destroy]

  def drafts
    @items = current_user.items.draft.order(updated_at: :desc)
  end

  def listings
    @items = current_user.items.order(entry_deadline_at: :asc)
  end

  # GET /items
  def index
    @items = Item.published.order(entry_deadline_at: :asc)
  end

  # GET /items/1
  def show
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  def create
    @item = current_user.items.build(item_params)

    if params[:publish]
      if @item.valid?(:publish)
        @item.status = :published
        @item.save!
        redirect_to @item, notice: t("items.create.success")
      else
        render :new, status: :unprocessable_content
      end
    else
      if @item.save
        redirect_to drafts_path, notice: "下書き保存しました"
      else
        render :new, status: :unprocessable_content
      end
    end
  end

  # PATCH/PUT /items/1
  def update
    @item.assign_attributes(item_params)
    title_append = params[:item][:title_append]
    description_append = params[:item][:description_append]
    payment_method_append = params[:item][:payment_method_append]

    if title_append.present?
      @item.title = [ @item.title, title_append ].join(" ")
    end
    if description_append.present?
      @item.description = [ @item.description.presence, description_append ].compact.join("\n")
    end
    if payment_method_append.present?
      @item.payment_method = [ @item.payment_method, payment_method_append ].join(" ")
    end

    if params[:publish]
      if @item.valid?(:publish)
        @item.status = :published
        @item.save!
        redirect_to @item, notice: t("items.update.success"), status: :see_other
      else
        render :edit, status: :unprocessable_content
      end
    else
      if @item.save
        redirect_to drafts_path, notice: t("items.update.success"), status: :see_other
      else
        render :edit, status: :unprocessable_content
      end
    end
  end

  # DELETE /items/1
  def destroy
    @item.destroy!

    if @item.draft?
      redirect_to drafts_path, notice: "下書きを削除しました", status: :see_other
    else
      redirect_to items_path, notice: t("items.destroy.success"), status: :see_other
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def item_params
      params.expect(item: [ :title, :description, :price, :shipping_fee_payer, :payment_method, :entry_deadline_at, :status, images: [] ])
    end

    def ensure_user
      @items = current_user.items
      @item = @items.find_by(id: params[:id])
      redirect_to items_path unless @item
    end
end
