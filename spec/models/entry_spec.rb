require 'rails_helper'

RSpec.describe Entry, type: :model do
  let(:seller) { create(:user) }

  before { ActiveJob::Base.queue_adapter = :test }

  describe "validations" do
    context "when user applies for same item twice" do
      let(:item) { create(:item, :published, user: seller) }
      let(:applier) { create(:user) }

      before { create(:entry, item: item, user: applier) }

      it "validates applying twice" do
        second_entry = build(:entry, item: item, user: applier)

        expect(second_entry.valid?).to be false
        expect(second_entry.errors.full_messages).to include("ユーザーはこの商品にすでに応募しています")
      end
    end
  end

  describe ".by_target" do
    let(:applier) { create(:user) }
    let!(:applied_entry) { create(:entry, user: applier) }
    let!(:won_entry) { create(:entry, :won, user: applier) }
    let!(:lost_entry) { create(:entry, :lost, user: applier) }

    context "when target is applied" do
      it "returns applied entries" do
        expect(applier.entries.by_target("applied")).to contain_exactly(applied_entry)
      end
    end

    context "when target is won" do
      it "returns won entries" do
        expect(applier.entries.by_target("won")).to contain_exactly(won_entry)
      end
    end

    context "when target is lost" do
      it "returns lost entries" do
        expect(applier.entries.by_target("lost")).to contain_exactly(lost_entry)
      end
    end

    context "when target is invalid" do
      it "returns all entries" do
        expect(applier.entries.by_target("invalid_status")).to contain_exactly(applied_entry, won_entry, lost_entry)
      end
    end
  end

  describe "#cannot_apply_for_own_item" do
    let(:item) { create(:item, :published, user: seller) }
    let(:entry) { build(:entry, item: item, user: seller) }

    it "validates applying for own item" do
      expect(entry.valid?).to be false
      expect(entry.errors.full_messages).to include("自分の出品物には応募できません")
    end
  end

  describe "#cannot_apply_for_expired_item" do
    let(:item) { create(:item, :published, user: seller, entry_deadline_at: entry_deadline_at) }
    let(:applier) { create(:user) }

    context "when applying for item whose deadline was yesterday" do
      let(:entry_deadline_at) { Date.yesterday.end_of_day }
      let(:entry) { build(:entry, item: item, user: applier) }

      it "validates applying for expired item" do
        expect(entry.valid?).to be false
        expect(entry.errors.full_messages).to include("締切の過ぎた商品には応募できません")
      end
    end

    context "when applying for item whose deadline is today" do
      let(:entry_deadline_at) { Date.current.end_of_day }
      let(:entry) { build(:entry, item: item, user: applier) }

      it "can apply for unexpired item" do
        expect(entry.valid?).to be true
        expect(entry.errors.full_messages).to be_empty
      end
    end
  end

  describe "#cannot_apply_for_closed_item" do
    let(:item) { create(:item, :closed, user: seller) }
    let(:applier) { create(:user) }
    let(:entry) { build(:entry, item: item, user: applier) }

    it "validates applying for closed item" do
      expect(entry.valid?).to be false
      expect(entry.errors.full_messages).to include("公開終了した商品には応募できません")
    end
  end
end
