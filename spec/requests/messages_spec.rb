require 'rails_helper'

RSpec.describe "/messages", type: :request do
  let(:seller) { create(:user) }
  let(:buyer) { create(:user) }
  let(:item) { create(:item, :with_max_five_images, :sold, user: seller) }

  let(:valid_attributes) {
    {
      user: buyer,
      item: item,
      body: "有効なメッセージ"
    }
  }

  let(:invalid_attributes) {
    {
      user: buyer,
      item: item,
      body: ""
    }
  }

  describe "GET /index" do
    context "when other user login" do
      it "redirects to items" do
        other_user = create(:user)
        login(other_user)
        get transaction_messages_path(item)
        expect(response).to redirect_to(items_path)
      end
    end

    context "when buyer login" do
      it "renders a successful response" do
        login(buyer)
        create(:entry, :won, item: item, user: buyer)
        Message.create! valid_attributes
        get transaction_messages_path(item)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /create" do
    before { login(buyer) }

    context "with valid parameters" do
      it "creates a new Message" do
        create(:entry, :won, item: item, user: buyer)
        expect {
          post transaction_messages_path(item), params: { message: valid_attributes }
        }.to change(Message, :count).by(1)
      end

      it "redirects to the message index" do
        create(:entry, :won, item: item, user: buyer)
        post transaction_messages_path(item), params: { message: valid_attributes }
        expect(response).to redirect_to(transaction_messages_path(item))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Message" do
        create(:entry, :won, item: item, user: buyer)
        expect {
          post transaction_messages_path(item), params: { message: invalid_attributes }
        }.not_to change(Message, :count)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        create(:entry, :won, item: item, user: buyer)
        post transaction_messages_path(item), params: { message: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
