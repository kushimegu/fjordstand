class CommentsController < ApplicationController
  before_action :set_item
  before_action :set_comment, only: [ :destroy ]
  before_action :require_admin, only: [ :destroy ]

  # POST /comments
  def create
    @comment = current_user.comments.new(comment_params)
    @comment.item_id = @item.id

    if @comment.save
      redirect_to @item, notice: "コメントを送信しました"
    else
      render "items/show", status: :unprocessable_content
    end
  end

  # DELETE /comments/1
  def destroy
    @comment.destroy!
    redirect_to @item, notice: "コメントを削除しました", status: :see_other
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_item
    @item = Item.find(params[:item_id])
  end

  def set_comment
    @comment = @item.comments.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def comment_params
    params.expect(comment: [ :body ])
  end

  def require_admin
    unless current_user.admin?
      redirect_to @item, alert: "削除する権限がありません"
    end
  end
end
