class Items::ListingsController < ApplicationController
  def index
    @listings = current_user.items
                            .by_target(params[:status])
                            .order(entry_deadline_at: :desc, updated_at: :desc)
                            .includes(:winner, images_attachments: :blob)
                            .page(params[:page])
                            .per(16)
  end
end
