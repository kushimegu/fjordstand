require 'rails_helper'

RSpec.describe ApplicationController, type: :request do
  let!(:user) { create(:user) }

  describe "#current_user" do
    context "when user is logged in" do
      it "returns the current user" do
        login(user)
        get items_path
        expect(controller.send(:current_user)).to eq(user)
      end

      it "memoizes the current user" do
        login(user)
        get items_path
        first_call = controller.send(:current_user)
        expect(controller.send(:current_user)).to equal(first_call)
      end
    end

    context "when no user is logged in" do
      it "returns nil" do
        get root_path
        expect(controller.send(:current_user)).to be_nil
      end
    end

    context "when session contains invalid user_id" do
      before do
        login(user)
        user.destroy
      end

      it "returns nil" do
        get items_path

        expect(controller.send(:current_user)).to be_nil
      end
    end
  end

  describe "#logged_in?" do
    context "when user is logged in" do
      it "returns true" do
        login(user)
        get items_path
        expect(controller.send(:logged_in?)).to be true
      end
    end

    context "when no user is logged in" do
      it "returns false" do
        get root_path
        expect(controller.send(:logged_in?)).to be false
      end
    end
  end

  describe "#authenticate_user!" do
    context "when user is logged in" do
      it "allows access" do
        login(user)
        get items_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when no user is logged in" do
      it "redirects to root path" do
        get items_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "#preload_current_user_notifications" do
    let!(:item) { create(:item) }

    it "preloads unread notifications" do
      create(:notification, :for_item, notifiable: item, user: user)
      login(user)
      get items_path
      current_user = controller.send(:current_user)
      expect(current_user.notifications.select { |n| !n.read? }.present?).to be true
    end
  end
end
