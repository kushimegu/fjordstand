require 'rails_helper'

RSpec.describe "Items::Closes", type: :request do
  let!(:user) { create(:user) }
  let!(:item) { create(:item, :published, user: user) }

  before { login(user) }

  describe "PATCH /update" do
    it "updates the requested item" do
      patch item_close_path(item_id: item.id)
      item.reload
      expect(item.status).to eq("closed")
    end

    it "redirects to the listings" do
      patch item_close_path(item_id: item.id)
      item.reload
      expect(response).to redirect_to(listings_path)
    end
  end
end
