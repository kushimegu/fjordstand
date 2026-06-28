class Items::ListingsController < ApplicationController
  PER_PAGE = 16

  def index
    item_scope = current_user.items
    item_scope = item_scope.where(status: params[:status]) if params[:status].present?
    @listings = item_scope.order(entry_deadline_at: :desc, updated_at: :desc)
                          .includes(:winner, first_image_attachment: { blob: :variant_records })
                          .page(params[:page])
                          .per(PER_PAGE)
  end
end
