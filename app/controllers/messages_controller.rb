class MessagesController < ApplicationController
  before_action :set_item
  before_action :authorize_user
  before_action :set_message, only: [ :destroy ]
  before_action :require_admin, only: [ :destroy ]

  # GET /messages
  def index
    @messages = @item.messages.includes(:user).order(:created_at)
    @message = @item.messages.build
    current_user.notifications
                .unread
                .where(notifiable_type: "Message", notifiable_id: @item.messages.select(:id))
                .update_all(read: true)
  end

  # POST /messages
  def create
    @message = @item.messages.build(message_params)
    @message.user = current_user

    if @message.save
      redirect_to transaction_messages_path(@item), notice: "メッセージを送信しました"
    else
      @messages = @item.messages.includes(:user).order(:created_at)
      render :index, status: :unprocessable_content
    end
  end

  # DELETE /messages/1
  def destroy
    @message.destroy!
    redirect_to transaction_messages_path(@item), notice: "コメントを削除しました", status: :see_other
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
    return if current_user.admin?

    redirect_to items_path, alert: "この連絡ページを閲覧する権限がありません"
  end

  def set_message
    @message = @item.messages.find(params[:id])
  end

  def require_admin
    unless current_user.admin?
      redirect_to transaction_messages_path(@item), alert: "削除する権限がありません"
    end
  end
end
