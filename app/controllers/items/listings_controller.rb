class Items::ListingsController < ApplicationController
  def index
    listings_scope = current_user.items
                                  .by_nearest_deadline.reverse_order
                                  .includes(:winner, images_attachments: :blob)
                                  .by_target(params[:status])
    @my_entries  = current_user.entries.where(item: listings_scope).index_by(&:item_id)
    @my_watches  = current_user.watches.where(item: listings_scope).pluck(:item_id).to_set
    @listings = listings_scope.page(params[:page]).per(16)
  end
end
