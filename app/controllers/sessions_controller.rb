class SessionsController < ApplicationController
  skip_before_action :check_logged_in, only: :create
  def create
    auth = request.env["omniauth.auth"]
    user = User.from_omniauth(auth)
    if user
      reset_session
      session[:user_id] = user.id
      redirect_to items_path, notice: "ログインしました"
    else
      redirect_to root_path, alert: "FjordBootCampのDiscordサーバに参加していません"
    end
  end

  def failure
    redirect_to root_path, alert: "ログインがキャンセルされました"
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "ログアウトしました"
  end
end
