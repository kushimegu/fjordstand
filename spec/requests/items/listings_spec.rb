require 'rails_helper'

RSpec.describe "Items::Listings", type: :request do
  let(:user) { create(:user) }

  describe "GET /index" do
    before { login(user) }

    context "when listings exists" do
      let!(:draft_item) { create(:item, user: user) }
      let!(:published_item) { create(:item, :published, user: user) }
      let!(:sold_item) { create(:item, :sold, user: user) }
      let!(:closed_item) { create(:item, :closed, user: user) }

      it "returns items including draft with http success" do
        get listings_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(published_item.title, sold_item.title, closed_item.title, draft_item.title)
      end
    end

    context "when no listings exists" do
      it "return message with http success" do
        get listings_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("該当する商品はありません")
      end
    end

    context "when filtering by published status" do
      let!(:draft_item) { create(:item, user: user) }
      let!(:published_item) { create(:item, :published, user: user) }
      let!(:sold_item) { create(:item, :sold, user: user) }
      let!(:closed_item) { create(:item, :closed, user: user) }

      it "returns only published item" do
        get listings_path(status: "published")

        expect(response).to have_http_status(:success)
        expect(response.body).to include(published_item.title)
        expect(response.body).not_to include(draft_item.title, sold_item.title, closed_item.title)
      end
    end

    context "when filtering by sold status" do
      let!(:draft_item) { create(:item, user: user) }
      let!(:published_item) { create(:item, :published, user: user) }
      let!(:sold_item) { create(:item, :sold, user: user) }
      let!(:closed_item) { create(:item, :closed, user: user) }

      it "returns only sold item" do
        get listings_path(status: "sold")

        expect(response).to have_http_status(:success)
        expect(response.body).to include(sold_item.title)
        expect(response.body).not_to include(draft_item.title, published_item.title, closed_item.title)
      end
    end

    context "when filtering by closed status" do
      let!(:draft_item) { create(:item, user: user) }
      let!(:published_item) { create(:item, :published, user: user) }
      let!(:sold_item) { create(:item, :sold, user: user) }
      let!(:closed_item) { create(:item, :closed, user: user) }

      it "returns only closed item" do
        get listings_path(status: "closed")

        expect(response).to have_http_status(:success)
        expect(response.body).to include(closed_item.title)
        expect(response.body).not_to include(draft_item.title, published_item.title, sold_item.title)
      end
    end

    context "when filtering by invalid status" do
      before do
        create(:item, user: user)
        create(:item, :published, user: user)
        create(:item, :sold, user: user)
        create(:item, :closed, user: user)
      end

      it "returns no listings" do
        get listings_path(status: "invalid")

        expect(response).to have_http_status(:success)
        expect(response.body).to include("該当する商品はありません")
      end
    end
  end
end
