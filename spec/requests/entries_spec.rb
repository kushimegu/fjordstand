require 'rails_helper'

RSpec.describe "/entries", type: :request do
  let(:user) { create(:user) }

  before { login(user) }

  describe "GET /index" do
    context "when entry exists" do
      let!(:applied_entry) { create(:entry, user: user) }
      let!(:won_entry) { create(:entry, :won, user: user) }
      let!(:lost_entry) { create(:entry, :lost, user: user) }

      it "returns current users entries with http success" do
        get entries_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(applied_entry.item.title, won_entry.item.title, lost_entry.item.title)
      end
    end

    context "when no entry exist" do
      it "returns empty array with http success" do
        get entries_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("該当する商品はありません")
      end
    end

    context "when filtering by applied status" do
      let!(:applied_entry) { create(:entry, user: user) }
      let!(:won_entry) { create(:entry, :won, user: user) }
      let!(:lost_entry) { create(:entry, :lost, user: user) }

      it "returns applied entries" do
        get entries_path(status: "applied")

        expect(response).to have_http_status(:success)
        expect(response.body).to include(applied_entry.item.title)
        expect(response.body).not_to include(won_entry.item.title, lost_entry.item.title)
      end
    end

    context "when filtering by won status" do
      let!(:applied_entry) { create(:entry, user: user) }
      let!(:won_entry) { create(:entry, :won, user: user) }
      let!(:lost_entry) { create(:entry, :lost, user: user) }

      it "returns applied entries" do
        get entries_path(status: "won")

        expect(response).to have_http_status(:success)
        expect(response.body).to include(won_entry.item.title)
        expect(response.body).not_to include(applied_entry.item.title, lost_entry.item.title)
      end
    end

    context "when filtering by lost status" do
      let!(:applied_entry) { create(:entry, user: user) }
      let!(:won_entry) { create(:entry, :won, user: user) }
      let!(:lost_entry) { create(:entry, :lost, user: user) }

      it "returns applied entries" do
        get entries_path(status: "lost")

        expect(response).to have_http_status(:success)
        expect(response.body).to include(lost_entry.item.title)
        expect(response.body).not_to include(won_entry.item.title, applied_entry.item.title)
      end
    end

    context "when filtering by invalid status" do
      let!(:applied_entry) { create(:entry, user: user) }
      let!(:won_entry) { create(:entry, :won, user: user) }
      let!(:lost_entry) { create(:entry, :lost, user: user) }

      it "returns all entries" do
        get entries_path(status: "invalid_status")

        expect(response).to have_http_status(:success)
        expect(response.body).to include(applied_entry.item.title, won_entry.item.title, lost_entry.item.title)
      end
    end
  end

  describe "POST /create" do
    context "when entry is valid" do
      let(:item) { create(:item, :published) }

      it "creates a new Entry" do
        expect {
          post item_entries_path(item)
        }.to change(Entry, :count).by(1)
        expect(response).to redirect_to(item_path(item))
      end
    end

    context "when entry is invalid" do
      let(:expired_item) { create(:item, :published, entry_deadline_at: Date.yesterday) }

      it "does not create a new Entry" do
        expect {
          post item_entries_path(expired_item)
        }.not_to change(Entry, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    let(:item) { create(:item, :published) }

    it "destroys the requested entry" do
      entry = item.entries.create!(user: user)
      expect {
        delete item_entries_path(item)
      }.to change(Entry, :count).by(-1)
      expect(response).to redirect_to(item_path(item))
    end
  end
end
