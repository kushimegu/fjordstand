class Items::ListingsController < ApplicationController
  def index
    listings_scope = current_user.items
                              .includes(:winner, images_attachments: :blob)
                              .by_target(params[:status])
                              .order(entry_deadline_at: :desc, updated_at: :desc)
    @my_entries  = current_user.entries.where(item: listings_scope).index_by(&:item_id)
    @my_watches  = current_user.watches.where(item: listings_scope).pluck(:item_id).to_set
    @listings = listings_scope.page(params[:page]).per(16)
  end
end
