class CommentsController < ApplicationController
  before_action :set_item

  # POST /comments
  def create
    raise ActionController::RoutingError, "Not Found" unless @item.commentable?

    @comment = current_user.comments.new(comment_params)
    @comment.item_id = @item.id

    if @comment.save
      redirect_to @item, notice: "コメントを投稿しました"
    else
      render "items/show", status: :unprocessable_content
    end
  end

  # DELETE /comments/1
  def destroy
    raise ActionController::RoutingError, "Not Found" unless current_user.admin?

    @comment = @item.comments.find(params[:id])
    @comment.destroy!
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
end
