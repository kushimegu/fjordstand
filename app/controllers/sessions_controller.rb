class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: :create

  def create
    auth = request.env["omniauth.auth"]
    user = User.from_omniauth(auth)
    if user
      reset_session
      session[:user_id] = user.id
      redirect_to items_path, notice: "ログインしました"
    elsif user == :not_member
      redirect_to root_path, alert: "FjordBootCampのDiscordサーバーに参加していません"
    else
      redirect_to root_path, alert: "ログインに失敗しました"
    end
  end

  def failure
    redirect_to root_path
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "ログアウトしました", status: :see_other
  end
end
