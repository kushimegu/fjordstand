class ApplicationController < ActionController::Base
  include SessionsHelper

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  before_action :check_logged_in
  before_action :preload_current_user_notifications, if: :logged_in?

  private

  def check_logged_in
    return if current_user

    redirect_to root_path
  end

  def preload_current_user_notifications
    current_user.notifications.unread.load
  end
end
