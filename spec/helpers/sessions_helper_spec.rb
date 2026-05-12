require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  let(:user) { create(:user) }

  describe "#current_user" do
    context "when there is user_id in session" do
      before { session[:user_id] = user.id }

      it "returns user" do
        expect(helper.current_user).to eq(user)
      end

      it "memorizes user" do
        allow(User).to receive(:find_by).and_return(user)
        helper.current_user
        helper.current_user
        expect(User).to have_received(:find_by).once
      end
    end

    context "when there is no user_id in session" do
      it "returns nil" do
        expect(helper.current_user).to be_nil
      end
    end
  end
end
