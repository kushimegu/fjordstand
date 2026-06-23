class ConversationsController < ApplicationController
  PER_PAGE = 10

  def index
    @items = current_user.dealing_items
                          .order(updated_at: :desc)
                          .includes(:user, :winner, first_image_attachment: { blob: :variant_records }, messages: :notifications, notifications: :notifiable)
                          .page(params[:page])
                          .per(PER_PAGE)
  end
end
