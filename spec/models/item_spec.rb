require 'rails_helper'

RSpec.describe Item, type: :model do
  describe "set_entry_deadline_at_end_of_day" do
    let(:item) { build(:item, entry_deadline_at: entry_deadline_at) }

    context "when entry_deadline_at is given from date_field" do
      let(:entry_deadline_at) { "2025-11-17" }

      it "sets entry_deadline_at to end of day" do
        item.save!
        expect(item.entry_deadline_at.to_i).to eq (Time.zone.parse("2025-11-17 23:59:59").to_i)
      end
    end
  end

  describe "validate price_not_change_after_published" do
    let(:user) { create(:user, uid: "1234567890") }
    let(:item) { create(:item, :with_max_five_images, user: user, price: 1000, status: :draft) }

    context "when item is already published" do
      before { item.update!(status: :published) }

      it "validates price to not change" do
        item.assign_attributes(price: 1200)

        expect(item.valid?(:publish)).to be false
        expect(item.errors[:price]).to include("は出品後に変更できません")
      end
    end

    context "when item is draft" do
      it "allows price change" do
        item.assign_attributes(price: 1200)

        item.valid?(:publish)
        expect(item.errors.full_messages).to be_empty
      end
    end
  end

  describe "validate deadline_today_or_later" do
    let(:user) { create(:user, uid: "1234567890") }
    let(:item) { build(:item, :with_max_five_images, user: user, entry_deadline_at: entry_deadline_at, status: :draft) }

    context "when setting deadline to yesterday" do
      let(:entry_deadline_at) { Date.yesterday }

      it "validates deadline to not be earlier than today" do
        expect(item.valid?(:publish)).to be false
        expect(item.errors[:entry_deadline_at]).to include ("は本日以降に設定してください")
      end
    end

    context "when setting deadline to today" do
      let(:entry_deadline_at) { Date.current }

      it "can set deadline to today" do
        item.valid?(:publish)
        expect(item.errors.full_messages).to be_empty
      end
    end

    context "when setting deadline to tomorrow" do
      let(:entry_deadline_at) { Date.tomorrow }

      it "can set deadline to tomorrow" do
        item.valid?(:publish)
        expect(item.errors.full_messages).to be_empty
      end
    end
  end

  describe "validate deadline_not_change_earlier_after_published" do
    let(:user) { create(:user, uid: "1234567890") }
    let(:item) { create(:item, :with_max_five_images, user: user, entry_deadline_at: Date.current + 5.days, status: :published) }

    context "when setting deadline to earlier date" do
      it "validates deadline to not change" do
        item.assign_attributes(entry_deadline_at: Date.current + 2.days)

        expect(item.valid?(:publish)).to be false
        expect(item.errors[:entry_deadline_at]).to include("は元の締切日以降に設定してください")
      end
    end

    context "when setting deadline to later date" do
      it "allows deadline change" do
        item.assign_attributes(entry_deadline_at: Date.current + 7.days)

        item.valid?(:publish)
        expect(item.errors.full_messages).to be_empty
      end
    end
  end
end
