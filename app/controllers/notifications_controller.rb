class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications
                                  .by_target(params[:status])
                                  .order(created_at: :desc)
                                  .preload(notifiable: [ :user, { item: [ :user, :winner ] } ])
                                  .page(params[:page])
                                  .per(20)
  end
end
