class CommentsController < ApplicationController
  before_action :set_item

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
