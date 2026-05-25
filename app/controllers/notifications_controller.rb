class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications
                                  .includes(:notifiable)
                                  .by_target(params[:status])
                                  .order(created_at: :desc)
                                  .page(params[:page])
                                  .per(20)
  end
end
