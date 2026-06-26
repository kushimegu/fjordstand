class Items::ListingsController < ApplicationController
  PER_PAGE = 16

  def index
    @listings = current_user.items
                            .by_target(params[:status])
                            .order(entry_deadline_at: :desc, updated_at: :desc)
                            .includes(:winner, first_image_attachment: { blob: :variant_records })
                            .page(params[:page])
                            .per(PER_PAGE)
  end
end
