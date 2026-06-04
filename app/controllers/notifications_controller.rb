class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications
                                  .preload(notifiable: [ :user, { item: [ :user, :winner ] } ])
                                  .by_target(params[:status])
                                  .order(created_at: :desc)
                                  .page(params[:page])
                                  .per(20)
  end
end
