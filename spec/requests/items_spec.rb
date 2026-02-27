require 'rails_helper'

RSpec.describe "/items", type: :request do
  let(:user) { create(:user) }

  before do
    webhook_double = instance_double(DiscordWebhook, notify_item_published: true, notify_item_closed: true, notify_item_deadline_extended: true, notify_lottery_skipped: true)
    allow(DiscordWebhook).to receive(:new).and_return(webhook_double)
    login user
  end

  describe "GET /drafts" do
    context "when draft exists" do
      it "returns draft items with http success" do
        draft_item = create(:item, user: user)
        published_item = create(:item, :with_max_five_images, :published, user: user)

        get drafts_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(draft_item.title)
        expect(response.body).not_to include(published_item.title)
      end
    end

    context "when no draft exists" do
      it "returns message with http success" do
        published_item = create(:item, :with_max_five_images, :published, user: user)
        get drafts_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("下書きはありません")
        expect(response.body).not_to include(published_item.title)
      end
    end
  end

  describe "GET /listings" do
    context "when listings exists" do
      it "returns items without draft with http success" do
        draft_item = create(:item, user: user)
        published_item = create(:item, :with_max_five_images, :published, user: user)
        sold_item = create(:item, :with_max_five_images, :sold, user: user)
        closed_item = create(:item, :with_max_five_images, :closed, user: user)
        get listings_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(published_item.title)
        expect(response.body).to include(sold_item.title)
        expect(response.body).to include(closed_item.title)
        expect(response.body).not_to include(draft_item.title)
      end
    end

    context "when no listings exists" do
      it "return message with http success" do
        draft_item = create(:item, user: user)
        get listings_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("該当する商品はありません")
        expect(response.body).not_to include(draft_item.title)
      end
    end

    context "when filtering by published status" do
      it "returns only published item" do
        published_item = create(:item, :with_max_five_images, :published, user: user)
        sold_item = create(:item, :with_max_five_images, :sold, user: user)
        closed_item = create(:item, :with_max_five_images, :closed, user: user)
        get listings_path(status: "published")

        expect(response).to have_http_status(:success)
        expect(response.body).to include(published_item.title)
        expect(response.body).not_to include(sold_item.title)
        expect(response.body).not_to include(closed_item.title)
      end
    end

    context "when filtering by sold status" do
      it "returns only sold item" do
        published_item = create(:item, :with_max_five_images, :published, user: user)
        sold_item = create(:item, :with_max_five_images, :sold, user: user)
        closed_item = create(:item, :with_max_five_images, :closed, user: user)
        get listings_path(status: "sold")

        expect(response).to have_http_status(:success)
        expect(response.body).not_to include(published_item.title)
        expect(response.body).to include(sold_item.title)
        expect(response.body).not_to include(closed_item.title)
      end
    end

    context "when filtering by closed status" do
      it "returns only closed item" do
        published_item = create(:item, :with_max_five_images, :published, user: user)
        sold_item = create(:item, :with_max_five_images, :sold, user: user)
        closed_item = create(:item, :with_max_five_images, :closed, user: user)
        get listings_path(status: "closed")

        expect(response).to have_http_status(:success)
        expect(response.body).not_to include(published_item.title)
        expect(response.body).not_to include(sold_item.title)
        expect(response.body).to include(closed_item.title)
      end
    end

    context "when filtering by invalid status" do
      it "returns all listings" do
        published_item = create(:item, :with_max_five_images, :published, user: user)
        sold_item = create(:item, :with_max_five_images, :sold, user: user)
        closed_item = create(:item, :with_max_five_images, :closed, user: user)
        get listings_path(status: "invalid")

        expect(response).to have_http_status(:success)
        expect(response.body).to include(published_item.title)
        expect(response.body).to include(sold_item.title)
        expect(response.body).to include(closed_item.title)
      end
    end
  end

  describe "GET /index" do
    context "when item exists" do
      it "returns item with http success" do
        item = create(:item, :with_max_five_images, :published)
        get items_path

        expect(response).to be_successful
        expect(response.body).to include(item.title)
      end
    end

    context "when no item exists" do
      it "returns message with http success" do
        get items_path

        expect(response).to be_successful
        expect(response.body).to include("現在購入希望を出せる商品がありません")
      end
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      item = create(:item, :with_max_five_images, :published)
      get item_url(item)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_item_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      item = create(:item, :with_max_five_images, :published, user: user)
      get edit_item_url(item)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "when save as published with valid parameters" do
      let(:valid_attributes) { attributes_for(:item).merge(images: [fixture_file_upload("book1.png")]) }

      it "creates a new Item" do
        expect {
          post items_url, params: { item: valid_attributes, publish: true }
        }.to change(Item, :count).by(1)

        expect(Item.last).to be_published
      end

      it "redirects to the created item" do
        post items_url, params: { item: valid_attributes, publish: true }
        expect(response).to redirect_to(item_url(Item.last))
      end
    end

    context "when save as published with invalid parameters" do
      let(:invalid_attributes) { attributes_for(:item) }

      it "does not create a new Item" do
        expect {
          post items_url, params: { item: invalid_attributes, publish: true }
        }.not_to change(Item, :count)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post items_url, params: { item: invalid_attributes, publish: true }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when save as draft" do
      let(:valid_attributes) { attributes_for(:item)}

      it "creates a new Item" do
        expect {
          post items_url, params: { item: valid_attributes }
        }.to change(Item, :count).by(1)
      end

      it "redirects to the drafts" do
        post items_url, params: { item: valid_attributes }
        expect(response).to redirect_to(drafts_path)
      end
    end
  end

  describe "PATCH /update" do
    context "update as closed" do
      it "updates the requested item" do
        item = create(:item, :with_max_five_images, :published, user: user)
        patch item_url(item), params: { close: true }
        item.reload
        expect(item.status).to eq("closed")
      end

      it "redirects to the listings" do
        item = create(:item, :with_max_five_images, :published, user: user)
        patch item_url(item), params: { close: true }
        item.reload
        expect(response).to redirect_to(listings_path)
      end
    end

    context "update as published with valid parameters" do
      let(:new_attributes) { { title_append: "初版" } }

      it "updates the requested item" do
        item = create(:item, :with_max_five_images, :published, user: user, title: "技術書")
        patch item_url(item), params: { item: new_attributes, publish: true }
        item.reload
        expect(item.title).to eq("技術書 初版")
      end

      it "redirects to the item" do
        item = create(:item, :with_max_five_images, :published, user: user, title: "技術書")
        patch item_url(item), params: { item: new_attributes, publish: true }
        item.reload
        expect(response).to redirect_to(item_url(item))
      end
    end

    context "update as published with invalid parameters" do
      let(:invalid_attributes) { { price: 1200 } }

      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        item = create(:item, :with_max_five_images, :published, user: user, price: 1000)
        patch item_url(item), params: { item: invalid_attributes, publish: true }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "update as draft" do
      let(:new_attributes) { { title: "初版" } }

      it "updates the requested item" do
        item = create(:item, user: user, title: "技術書")
        patch item_url(item), params: { item: new_attributes }
        item.reload
        expect(item.title).to eq("初版")
      end

      it "redirects to the drafts" do
        item = create(:item, user: user, title: "技術書")
        patch item_url(item), params: { item: new_attributes }
        item.reload
        expect(response).to redirect_to(drafts_path)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested item" do
      item = create(:item, :with_max_five_images, :published, user: user)
      expect {
        delete item_url(item)
      }.to change(Item, :count).by(-1)
    end

    it "redirects to the items list" do
      item = create(:item, :with_max_five_images, :published, user: user)
      delete item_url(item)
      expect(response).to redirect_to(items_url)
    end
  end
end
