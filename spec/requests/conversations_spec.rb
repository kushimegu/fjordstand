require 'rails_helper'

RSpec.describe "Conversations", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:sold_item) { create(:item, :sold, user: user) }
  let(:won_item) { create(:item, :sold) }

  before do
    create(:entry, :won, user: other_user, item: sold_item)
    create(:entry, :won, user: user, item: won_item)
    login user
  end

  describe "GET /index" do
    it "returns sold listing and won item" do
      get conversations_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(sold_item.title, won_item.title)
    end
  end
end
