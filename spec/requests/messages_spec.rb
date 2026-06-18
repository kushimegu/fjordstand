require 'rails_helper'

RSpec.describe "/messages", type: :request do
  let(:user) { create(:user) }
  let(:buyer) { create(:user) }
  let(:item) { create(:item, :sold, user: user) }
  let(:message) { create(:message, user: buyer, item: item) }

  before do
    create(:entry, :won, item: item, user: buyer)
    message
    create_list(:notification, 2, notifiable: message, user: user)
  end

  describe "GET /index" do
    context "when other user tries to access" do
      it "redirects to items" do
        other_user = create(:user)
        login(other_user)
        get conversation_messages_path(item)
        expect(response).to redirect_to(items_path)
      end
    end

    context "when buyer login" do
      before { login(user) }

      it "renders a successful response and marks all messages as read" do
        expect { get conversation_messages_path(item)}.to change { user.notifications.reload.map(&:read) }.from(all(be false)).to(all(be true))
        expect(response).to be_successful
      end
    end
  end

  describe "POST /create" do
    before { login(user) }

    context "with valid parameters" do
      let(:valid_attributes) { attributes_for(:message, item: item, user: user) }

      it "creates a new Message" do
        expect {
          post conversation_messages_path(item), params: { message: valid_attributes }
        }.to change(Message, :count).by(1)
        expect(response).to redirect_to(conversation_messages_path(item))
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { attributes_for(:message, item: item, user: user, body: "") }

      it "does not create a new Message" do
        expect {
          post conversation_messages_path(item), params: { message: invalid_attributes }
        }.not_to change(Message, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    context "when user tries to delete message" do
      it "redirects to messages" do
        login(user)
        expect {
          delete conversation_message_url(item, message)
        }.not_to change(Message, :count)
        expect(response).to redirect_to(conversation_messages_url(item))
      end
    end

    context "when admin deletes message" do
      let(:admin) { create(:user, :admin, uid: "123") }

      before { login (admin) }

      it "destroys the requested message" do
        expect {
          delete conversation_message_url(item, message)
        }.to change(Message, :count).by(-1)
        expect(response).to redirect_to(conversation_messages_url(item))
      end
    end
  end
end
