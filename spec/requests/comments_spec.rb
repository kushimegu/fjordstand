require 'rails_helper'

RSpec.describe "/comments", type: :request do
  let(:user) { create(:user) }
  let(:item) { create(:item, :published, user: user) }
  let(:valid_attributes) { attributes_for(:comment) }

  describe "POST /create" do
    before { login(user) }

    context "when item is not commentable" do
      it "returns status 404" do
        draft_item = create(:item, user: user)

        post item_comments_path(draft_item), params: { comment: valid_attributes }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with valid parameters" do
      it "creates a new Comment" do
        expect {
          post item_comments_path(item), params: { comment: valid_attributes }
        }.to change(Comment, :count).by(1)
        expect(response).to redirect_to(item_path(item))
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { attributes_for(:comment, body: "") }

      it "does not create a new Comment" do
        expect {
          post item_comments_path(item), params: { comment: invalid_attributes }
        }.not_to change(Comment, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    context "when user tries to delete comment" do
      before { login(user) }

      it "redirects to item" do
        comment = create(:comment, user: user, item: item)

        expect {
          delete item_comment_url(item, comment)
        }.not_to change(Comment, :count)
        expect(response).to redirect_to(item_url(item))
      end
    end

    context "when admin deletes comment" do
      let(:admin) { create(:user, :admin, uid: "123") }

      before { login (admin) }

      it "destroys the requested comment" do
        comment = create(:comment, user: user, item: item)

        expect {
          delete item_comment_url(item, comment)
        }.to change(Comment, :count).by(-1)
        expect(response).to redirect_to(item_url(item))
      end
    end
  end
end
