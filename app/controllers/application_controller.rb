class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :preload_current_user_notifications, if: :logged_in?

  def current_user
    return unless (user_id = session[:user_id])

    @current_user = User.find_by(id: user_id) unless defined?(@current_user)
    @current_user
  end

  def logged_in?
    !current_user.nil?
  end

  private

  def authenticate_user!
    return if current_user

    redirect_to root_path
  end

  def preload_current_user_notifications
    current_user.notifications.unread.load
  end
end
