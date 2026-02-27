require 'rails_helper'

RSpec.describe "/comments", type: :request do
  let(:user) { create(:user) }
  let(:item) { create(:item, :published, user: user) }

  let(:valid_attributes) { {
    body: "有効なコメント"
  } }

  let(:invalid_attributes) { {
    body: ""
  } }

  let(:webhook_double) { instance_double(DiscordWebhook, notify_item_published: true, notify_new_comment: true) }

  before do
    login(user)
    allow(DiscordWebhook).to receive(:new).and_return(webhook_double)
  end

  describe "POST /create" do
    context "with valid parameters" do
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
end
