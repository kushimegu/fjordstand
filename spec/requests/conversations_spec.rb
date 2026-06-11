require 'rails_helper'

RSpec.describe "Conversations", type: :request do
  let(:user) { create(:user) }

  before { login user }

  describe "GET /index" do
    it "returns http success" do
      get conversations_path
      expect(response).to have_http_status(:success)
    end
  end
end
