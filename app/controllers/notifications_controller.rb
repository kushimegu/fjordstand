class NotificationsController < ApplicationController
  PER_PAGE = 20

  def index
    notification_scope = current_user.notifications
    notification_scope = notification_scope.unread if params[:status] == "unread"
    @notifications = notification_scope.order(created_at: :desc)
                                        .preload(notifiable: [ :user, { item: [ :user, :winner ] } ])
                                        .page(params[:page])
                                        .per(PER_PAGE)
  end
end
