class SessionsController < ApplicationController
  skip_before_action :check_logged_in, only: :create
  def create
    auth = request.env["omniauth.auth"]
    if (user = User.from_omniauth(auth))
      reset_session
      session[:user_id] = user.id
    end
    redirect_to items_path, notice: "ログインしました"
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "ログアウトしました"
  end
end
