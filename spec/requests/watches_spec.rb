require 'rails_helper'

RSpec.describe "/watches", type: :request do
  let(:item) { create(:item, :with_max_five_images, :published) }
  let(:user) { create(:user) }

  before { login(user) }

  describe "GET /index" do
    context "when watch exists" do
      it "returns current users watches with http successful" do
        watch = create(:watch, item: item, user: user)

        get watches_path
        expect(response).to have_http_status(:success)

        expect(response.body).to include(watch.item.title)
      end
    end

    context "when no watches exist" do
      it "returns empty array with http success" do
        get entries_path
        expect(response).to have_http_status(:success)

        expect(response.body).to include("該当する商品はありません")
      end
    end
  end

  describe "POST /create" do
    context "when watch is valid" do
      it "creates a new Watch" do
        expect {
          post item_watches_path(item)
        }.to change{ item.watches.where(user: user).count }.by(1)
      end

      it "redirects to the item" do
        post item_watches_path(item)
        expect(response).to redirect_to(item)
      end
    end

    context "when watch is invalid" do
      it "does not create a new Watch" do
        create(:watch, item: item, user: user)
        expect {
          post item_watches_path(item)
        }.not_to change(Watch, :count)
      end

      it "renders a response with 422 status" do
        create(:watch, item: item, user: user)
        post item_watches_path(item)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested watch" do
      watch = item.watches.create!(user: user)
      expect {
        delete item_watches_path(item)
      }.to change(Watch, :count).by(-1)
    end

    it "redirects to the item" do
      watch = item.watches.create!(user: user)
      delete item_watches_path(item)
      expect(response).to redirect_to(item)
    end
  end
end
