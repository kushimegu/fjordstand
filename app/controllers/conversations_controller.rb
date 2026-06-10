class ConversationsController < ApplicationController
  def index
    @items = Item.in_transaction_with(current_user)
                  .order(updated_at: :desc)
                  .includes(:user, :winner, first_image_attachment: { blob: :variant_records }, messages: :notifications, notifications: :notifiable)
                  .page(params[:page])
                  .per(10)
  end
end
