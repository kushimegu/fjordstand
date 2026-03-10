require 'rails_helper'

RSpec.describe "/comments", type: :request do
  let(:user) { create(:user) }
  let(:item) { create(:item, :with_max_five_images, :published, user: user) }

  before do
    webhook_double = instance_double(DiscordWebhook, notify_item_published: true, notify_new_comment: true)
    allow(DiscordWebhook).to receive(:new).and_return(webhook_double)
  end

  describe "POST /create" do
    before { login(user) }

    context "with valid parameters" do
      let(:valid_attributes) { attributes_for(:comment) }

      it "creates a new Comment" do
        expect {
          post item_comments_path(item), params: { comment: valid_attributes }
        }.to change(Comment, :count).by(1)
      end

      it "redirects to the item" do
        post item_comments_path(item), params: { comment: valid_attributes }
        expect(response).to redirect_to(item_path(item))
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { attributes_for(:comment, body: "") }

      it "does not create a new Comment" do
        expect {
          post item_comments_path(item), params: { comment: invalid_attributes }
        }.not_to change(Comment, :count)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post item_comments_path(item), params: { comment: invalid_attributes }
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
      end

      it "redirects to item" do
        comment = create(:comment, user: user, item: item)

        delete item_comment_url(item, comment)
        expect(response).to redirect_to(item_url(item))
      end
    end
  end
end
