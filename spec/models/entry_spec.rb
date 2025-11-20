require 'rails_helper'

RSpec.describe Entry, type: :model do
  describe "cannot_apply_to_own_item" do
    let(:user) { create(:user, uid: "1234567890") }
    let(:item) { create(:item, :with_max_five_images, user: user, status: :published) }

    context "when trying to apply to own item" do
      let(:entry) { build(:entry, item: item, user: user, status: :pending) }

      it "validates applying to own item" do
        entry.valid?
        expect(entry.errors.full_messages).to include("自分の出品物には応募できません")
      end
    end
  end
end
