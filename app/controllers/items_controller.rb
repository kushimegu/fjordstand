class ItemsController < ApplicationController
  before_action :set_item, only: %i[ show edit update destroy ]

  # GET /items
  def index
    @items = Item.all
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

    if @item.save
      redirect_to @item, notice: t('items.create.success')
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /items/1
  def update
    if params[:remove_images]
      params[:remove_images].each do |id|
        @item.images.find(id).purge
      end
    end
    if @item.update(item_params)
      redirect_to @item, notice: t('items.update.success'), status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /items/1
  def destroy
    @item.destroy!
    redirect_to items_path, notice: t('items.destroy.success'), status: :see_other
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
end
