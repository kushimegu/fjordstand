class MessagesController < ApplicationController
  before_action :set_item
  before_action :authorize_user
  before_action :require_admin, only: %i[destroy]

  # GET /messages
  def index
    @messages = @item.messages.includes(:user).order(:created_at)
    @message = @item.messages.build
    current_user.mark_notifications_as_read!("Message", @item.message_ids)
  end

  # POST /messages
  def create
    @message = @item.messages.build(message_params)
    @message.user = current_user

    if @message.save
      redirect_to conversation_messages_path(@item), notice: "メッセージを送信しました"
    else
      @messages = @item.messages.includes(:user).order(:created_at)
      render :index, status: :unprocessable_content
    end
  end

  # DELETE /messages/1
  def destroy
    message = @item.messages.find(params[:id])

    message.destroy!
    redirect_to conversation_messages_path(@item), notice: "メッセージを削除しました", status: :see_other
  end

  private

  def set_item
    @item = Item.sold.find(params[:conversation_id])
  end

  # Only allow a list of trusted parameters through.
  def message_params
    params.expect(message: [ :body ])
  end

  def authorize_user
    return if @item.user_id == current_user.id
    return if @item.winner == current_user
    return if current_user.admin?

    redirect_to @item, alert: "この連絡ページを閲覧する権限がありません"
  end

  def require_admin
    redirect_to conversation_messages_path(@item), alert: "削除する権限がありません" unless current_user.admin?
  end
end
