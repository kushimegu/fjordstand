class MessagesController < ApplicationController
  before_action :set_item
  before_action :authorize_user

  # GET /messages
  def index
    @messages = @item.messages.includes(:user)
    @message = @item.messages.build
  end

  # POST /messages
  def create
    @message = @item.messages.build(message_params)
    @message.user = current_user

    if @message.save
      redirect_to transaction_messages_path(@item), notice: "メッセージを送信しました"
    else
      render :index, status: :unprocessable_content
    end
  end

  private
  def set_item
    @item = Item.find(params[:transaction_id])
  end

  # Only allow a list of trusted parameters through.
  def message_params
    params.expect(message: [ :body ])
  end

  def authorize_user
    return if @item.user_id == current_user.id
    return if @item.entries.exists?(user_id: current_user.id, status: :won)

    redirect_to items_path, alert: "この連絡ページを閲覧する権限がありません"
  end
end
