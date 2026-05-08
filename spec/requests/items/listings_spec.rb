require 'rails_helper'

RSpec.describe "Items::Listings", type: :request do
  let(:user) { create(:user) }

  describe "GET /index" do
    before { login(user) }

    context "when listings exists" do
      it "returns items with draft with http success" do
        draft_item = create(:item, user: user)
        published_item = create(:item, :published, user: user)
        sold_item = create(:item, :sold, user: user)
        closed_item = create(:item, :closed, user: user)
        get listings_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(published_item.title)
        expect(response.body).to include(sold_item.title)
        expect(response.body).to include(closed_item.title)
        expect(response.body).to include(draft_item.title)
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
      it "returns only published item" do
        published_item = create(:item, :published, user: user)
        sold_item = create(:item, :sold, user: user)
        closed_item = create(:item, :closed, user: user)
        get listings_path(status: "published")

        expect(response).to have_http_status(:success)
        expect(response.body).to include(published_item.title)
        expect(response.body).not_to include(sold_item.title)
        expect(response.body).not_to include(closed_item.title)
      end
    end

    context "when filtering by sold status" do
      it "returns only sold item" do
        published_item = create(:item, :published, user: user)
        sold_item = create(:item, :sold, user: user)
        closed_item = create(:item, :closed, user: user)
        get listings_path(status: "sold")

        expect(response).to have_http_status(:success)
        expect(response.body).not_to include(published_item.title)
        expect(response.body).to include(sold_item.title)
        expect(response.body).not_to include(closed_item.title)
      end
    end

    context "when filtering by closed status" do
      it "returns only closed item" do
        published_item = create(:item, :published, user: user)
        sold_item = create(:item, :sold, user: user)
        closed_item = create(:item, :closed, user: user)
        get listings_path(status: "closed")

        expect(response).to have_http_status(:success)
        expect(response.body).not_to include(published_item.title)
        expect(response.body).not_to include(sold_item.title)
        expect(response.body).to include(closed_item.title)
      end
    end

    context "when filtering by invalid status" do
      it "returns all listings" do
        published_item = create(:item, :published, user: user)
        sold_item = create(:item, :sold, user: user)
        closed_item = create(:item, :closed, user: user)
        get listings_path(status: "invalid")

        expect(response).to have_http_status(:success)
        expect(response.body).to include(published_item.title)
        expect(response.body).to include(sold_item.title)
        expect(response.body).to include(closed_item.title)
      end
    end
  end
end
