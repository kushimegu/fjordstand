class SessionsController < ApplicationController
  skip_before_action :check_logged_in, only: :create
  def create
    auth = request.env["omniauth.auth"]
    if (user = User.from_omniauth(auth))
      reset_session
      log_in user
    end
    redirect_to items_path
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
