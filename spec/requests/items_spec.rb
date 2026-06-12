require 'rails_helper'

RSpec.describe "/items", type: :request do
  let!(:user) { create(:user) }
  let!(:admin) { create(:user, :admin, uid: "123") }

  describe "GET /index" do
    before { login(user) }

    context "when item exists" do
      it "returns item with http success" do
        item = create(:item, :published)
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
      item = create(:item, :published)
      login(user)
      get item_url(item)
      expect(response).to be_successful
    end

    context "when accessed from notifications" do
      it "makes all notifications read" do
        item = create(:item, :published, user: user)
        create_list(:comment, 2, item: item, user: admin)
        expect(user.notifications.pluck(:read)).to all(be false)
        login(user)
        get item_path(item, from: :notifications)
        expect(user.notifications.reload.pluck(:read)).to all(be true)
      end
    end

    context "when accessed not from notifications" do
      it "does not change notifications read status" do
        item = create(:item, :published, user: user)
        create_list(:comment, 2, item: item, user: admin)
        expect(user.notifications.pluck(:read)).to all(be false)
        login(user)
        get item_path(item)
        expect(user.notifications.reload.pluck(:read)).to all(be false)
      end
    end
  end

  describe "GET /new" do
    before { login(user) }

    it "renders a successful response" do
      get new_item_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    before { login(user) }

    context "when item is editable" do
      it "renders a successful response" do
        item = create(:item, :published, user: user)
        get edit_item_url(item)
        expect(response).to be_successful
      end
    end

    context "when item is not editable" do
      it "redirects to the item page" do
        item = create(:item, :sold, user: user)
        get edit_item_url(item)
        expect(response).to redirect_to(item_url(item))
      end
    end
  end

  describe "POST /create" do
    before { login(user) }

    context "when save as published with valid parameters" do
      let(:valid_attributes) { attributes_for(:item).merge(images: [ fixture_file_upload("book1.png") ]) }

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
  end

  describe "PATCH /update" do
    before { login(user) }

    context "when item is not editable" do
      it "redirects to the item page" do
        item = create(:item, :sold, user: user, title: "技術書")
        patch item_url(item), params: { item: { title_append: "初版" } }
        expect(response).to redirect_to(item_url(item))
        expect(item.reload.title).to eq("技術書")
      end
    end

    context "when update as published with valid parameters" do
      let(:new_attributes) { { title_append: "初版" } }

      it "updates the requested item" do
        item = create(:item, :published, :with_item_image, user: user, title: "技術書")
        patch item_url(item), params: { item: new_attributes, publish: true }
        item.reload
        expect(item.title).to eq("技術書 初版")
      end

      it "redirects to the item" do
        item = create(:item, :published, :with_item_image, user: user, title: "技術書")
        patch item_url(item), params: { item: new_attributes, publish: true }
        item.reload
        expect(response).to redirect_to(item_url(item))
      end
    end

    context "when update as published with invalid parameters" do
      let(:invalid_attributes) { { price: 1200 } }

      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        item = create(:item, :published, user: user, price: 1000)
        patch item_url(item), params: { item: invalid_attributes, publish: true }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    context "when admin deletes published item" do
      before { login(admin) }

      it "destroys the requested item" do
        item = create(:item, :published, user: user)

        expect {
          delete item_url(item)
        }.to change(Item, :count).by(-1)
      end

      it "redirects to the items index" do
        item = create(:item, :published, user: user)

        delete item_url(item)
        expect(response).to redirect_to(items_url)
      end
    end
  end
end
