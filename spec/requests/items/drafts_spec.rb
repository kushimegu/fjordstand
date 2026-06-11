require 'rails_helper'

RSpec.describe "Items::Drafts", type: :request do
  let!(:user) { create(:user) }

  before { login(user) }

  describe "POST /create" do
    context "when save as draft" do
      let(:valid_attributes) { attributes_for(:item) }

      it "creates a new Item" do
        expect {
          post drafts_url, params: { item: valid_attributes }
        }.to change(Item, :count).by(1)
      end

      it "redirects to the listings" do
        post drafts_url, params: { item: valid_attributes }
        expect(response).to redirect_to(listings_path)
      end
    end
  end

  describe "PATCH /update" do
    let(:new_attributes) { { title: "初版" } }

    it "updates the requested item" do
      item = create(:item, user: user, title: "技術書")
      patch draft_url(item), params: { item: new_attributes }
      expect(item.reload.title).to eq("初版")
      expect(response).to redirect_to(listings_path)
    end
  end

  describe "DELETE /destroy" do
    context "when user deletes draft" do
      it "destroys the requested item" do
        item = create(:item, user: user)
        expect {
          delete draft_url(item)
        }.to change(Item, :count).by(-1)
        expect(response).to redirect_to(listings_path)
      end
    end

    context "when user tries to delete published item" do
      it "returns a 404 status" do
        item = create(:item, :published, user: user)
        expect {
          delete draft_url(item)
        }.not_to change(Item, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
