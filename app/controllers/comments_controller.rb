class CommentsController < ApplicationController
  before_action :set_item
  before_action :require_admin, only: %i[destroy]

  # POST /comments
  def create
    @item = Item.commentable.find(params[:item_id])

    @comment = @item.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @item, notice: "コメントを投稿しました"
    else
      render "items/show", status: :unprocessable_content
    end
  end

  # DELETE /comments/1
  def destroy
    @item.comments.find(params[:id]).destroy!
    redirect_to @item, notice: "コメントを削除しました", status: :see_other
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_item
    @item = Item.find(params[:item_id])
  end

  # Only allow a list of trusted parameters through.
  def comment_params
    params.expect(comment: [ :body ])
  end

  def require_admin
    redirect_to @item, alert: "削除する権限がありません" unless current_user.admin?
  end
end
