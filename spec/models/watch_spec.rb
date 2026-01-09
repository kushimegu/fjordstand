require 'rails_helper'

RSpec.describe Watch, type: :model do
  describe "validations" do
    context "when user registers for same item twice" do
      let(:item) { create(:item, :with_max_five_images, :published) }
      let(:user) { create(:user) }

      it "validates duplicate registration" do
        create(:watch, item: item, user: user)
        second_registration = build(:watch, item: item, user: user)

        is_valid = second_registration.valid?
        expect(is_valid).to be false
        expect(second_registration.errors.full_messages).to include("ユーザーはこのコメント欄をすでにWatchしています")
      end
    end
  end
end
