class TransactionsController < ApplicationController
  def index
    @items = Item.includes(:user, :winner, images_attachments: :blob, notifications: :notifiable)
                  .where(user_id: current_user.id, status: :sold)
                  .or(Item.where(id: Entry.where(user_id: current_user.id, status: :won).select(:item_id)))
                  .order(updated_at: :desc)
                  .page(params[:page])
                  .per(10)
  end
end
