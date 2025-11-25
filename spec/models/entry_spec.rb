require 'rails_helper'

RSpec.describe Entry, type: :model do
  let(:seller) { create(:user, uid: "1234567890") }

  describe "cannot_apply_for_own_item" do
    let(:item) { create(:item, :with_max_five_images, user: seller, status: :published) }
    let(:entry) { build(:entry, item: item, user: seller, status: :applied) }

    it "validates applying for own item" do
      entry.valid?
      expect(entry.errors.full_messages).to include("自分の出品物には応募できません")
    end
  end

  describe "cannot_apply_for_expired_item" do
    let(:item) { create(:item, :with_max_five_images, user: seller, status: :published, entry_deadline_at: Date.yesterday.end_of_day) }
    let(:buyer) { create(:user, uid: "1234567891") }
    let(:entry) { build(:entry, item: item, user: buyer, status: :applied) }

    it "validates applying for expired item" do
      entry.valid?
      expect(entry.errors.full_messages).to include("締切の過ぎた商品には応募できません")
    end
  end
end
