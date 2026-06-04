class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: :create

  def create
    auth = request.env["omniauth.auth"]
    user = User.from_omniauth(auth)
    if user
      reset_session
      session[:user_id] = user.id
      redirect_to items_path, notice: "ログインしました"
    else
      redirect_to root_path, alert: "FjordBootCampのDiscordサーバーに参加していません"
    end
  end

  def failure
    redirect_to root_path, alert: "ログインがキャンセルされました"
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "ログアウトしました", status: :see_other
  end
end
