require 'rails_helper'

RSpec.describe "/messages", type: :request do
  let(:seller) { create(:user) }
  let(:buyer) { create(:user) }
  let(:item) { create(:item, :with_item_image, :sold, user: seller) }

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
        create(:message, user: buyer, item: item)
        get transaction_messages_path(item)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /create" do
    before { login(buyer) }

    context "with valid parameters" do
      let(:valid_attributes) { attributes_for(:message, item: item, user: buyer) }

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
      let(:invalid_attributes) { attributes_for(:message, item: item, user: buyer, body: "") }

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

  describe "DELETE /destroy" do
    context "when user tries to delete message" do
      it "redirects to messages" do
        create(:entry, :won, item: item, user: buyer)
        login(buyer)
        message = create(:message, user: buyer, item: item)
        expect {
          delete transaction_message_url(item, message)
        }.not_to change(Message, :count)
        expect(response).to redirect_to(transaction_messages_url(item))
      end
    end

    context "when admin deletes message" do
      let(:admin) { create(:user, :admin, uid: "123") }

      before { login (admin) }

      it "destroys the requested message" do
        message = create(:message, user: buyer, item: item)

        expect {
          delete transaction_message_url(item, message)
        }.to change(Message, :count).by(-1)
      end

      it "redirects to item" do
        message = create(:message, user: buyer, item: item)

        delete transaction_message_url(item, message)
        expect(response).to redirect_to(transaction_messages_url(item))
      end
    end
  end
end
