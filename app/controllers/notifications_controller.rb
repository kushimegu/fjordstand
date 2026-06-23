class NotificationsController < ApplicationController
  PER_PAGE = 20

  def index
    @notifications = current_user.notifications
                                  .by_target(params[:status])
                                  .order(created_at: :desc)
                                  .preload(notifiable: [ :user, { item: [ :user, :winner ] } ])
                                  .page(params[:page])
                                  .per(PER_PAGE)
  end
end
