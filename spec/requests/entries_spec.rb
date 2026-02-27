require 'rails_helper'

RSpec.describe "/entries", type: :request do
  let(:user) { create(:user) }
  let(:published_item) { create(:item, :with_max_five_images, :published) }
  let(:sold_item_where_user_won) { create(:item, :with_max_five_images, :sold) }
  let(:sold_item_where_user_lost) { create(:item, :with_max_five_images, :sold) }
  let(:closed_item) { create(:item, :with_max_five_images, :closed) }

  before do
    login(user)
    webhook_double = instance_double(DiscordWebhook, notify_item_published: true)
    allow(DiscordWebhook).to receive(:new).and_return(webhook_double)
  end

  describe "GET /index" do
    context "when entry exists" do
      it "returns current users entries with http success" do
        applied_entry = create(:entry, item: published_item, user: user)
        won_entry = create(:entry, :won, item: sold_item_where_user_won, user: user)
        lost_entry = create(:entry, :lost, item: sold_item_where_user_lost, user: user)

        get entries_path
        expect(response).to have_http_status(:success)

        expect(response.body).to include(applied_entry.item.title)
        expect(response.body).to include(won_entry.item.title)
        expect(response.body).to include(lost_entry.item.title)
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
      it "returns applied entries" do
        applied_entry = create(:entry, item: published_item, user: user)
        won_entry = create(:entry, :won, item: sold_item_where_user_won, user: user)
        lost_entry = create(:entry, :lost, item: sold_item_where_user_lost, user: user)

        get entries_path(status: "applied")
        expect(response).to have_http_status(:success)

        expect(response.body).to include(applied_entry.item.title)
        expect(response.body).not_to include(won_entry.item.title)
        expect(response.body).not_to include(lost_entry.item.title)
      end
    end

    context "when filtering by won status" do
      it "returns applied entries" do
        applied_entry = create(:entry, item: published_item, user: user)
        won_entry = create(:entry, :won, item: sold_item_where_user_won, user: user)
        lost_entry = create(:entry, :lost, item: sold_item_where_user_lost, user: user)

        get entries_path(status: "won")
        expect(response).to have_http_status(:success)

        expect(response.body).to include(won_entry.item.title)
        expect(response.body).not_to include(applied_entry.item.title)
        expect(response.body).not_to include(lost_entry.item.title)
      end
    end

    context "when filtering by lost status" do
      it "returns applied entries" do
        applied_entry = create(:entry, item: published_item, user: user)
        won_entry = create(:entry, :won, item: sold_item_where_user_won, user: user)
        lost_entry = create(:entry, :lost, item: sold_item_where_user_lost, user: user)

        get entries_path(status: "lost")
        expect(response).to have_http_status(:success)

        expect(response.body).to include(lost_entry.item.title)
        expect(response.body).not_to include(won_entry.item.title)
        expect(response.body).not_to include(applied_entry.item.title)
      end
    end

    context "when filtering by invalid status" do
      it "returns all entries" do
        applied_entry = create(:entry, item: published_item, user: user)
        won_entry = create(:entry, :won, item: sold_item_where_user_won, user: user)
        lost_entry = create(:entry, :lost, item: sold_item_where_user_lost, user: user)

        get entries_path(status: "invalid_status")
        expect(response).to have_http_status(:success)

        expect(response.body).to include(applied_entry.item.title)
        expect(response.body).to include(won_entry.item.title)
        expect(response.body).to include(lost_entry.item.title)
      end
    end
  end

  describe "POST /create" do
    context "when entry is valid" do
      it "creates a new Entry" do
        expect {
          post item_entries_path(published_item)
        }.to change(Entry, :count).by(1)
      end

      it "redirects to the item" do
        post item_entries_path(published_item)
        expect(response).to redirect_to(item_path(published_item))
      end
    end

    context "when entry is invalid" do
      it "does not create a new Entry" do
        expect {
          post item_entries_path(closed_item)
        }.not_to change(Entry, :count)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post item_entries_path(closed_item)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested entry" do
      entry = published_item.entries.create!(user: user)
      expect {
        delete item_entries_path(published_item)
      }.to change(Entry, :count).by(-1)
    end

    it "redirects to the item" do
      entry = published_item.entries.create!(user: user)
      delete item_entries_path(published_item)
      expect(response).to redirect_to(item_path(published_item))
    end
  end
end
