require 'rails_helper'

RSpec.describe Entry, type: :model do
  let(:seller) { create(:user) }

  before do
    webhook_double = instance_double(DiscordWebhook, notify_item_published: true)
    allow(DiscordWebhook).to receive(:new).and_return(webhook_double)
  end

  describe "validations" do
    context "when user applies for same item twice" do
      let(:item) { create(:item, :with_max_five_images, :published, user: seller) }
      let(:applier) { create(:user) }

      it "validates applying twice" do
        create(:entry, item: item, user: applier)
        second_entry = build(:entry, item: item, user: applier)

        is_valid = second_entry.valid?
        expect(is_valid).to be false
        expect(second_entry.errors.full_messages).to include("ユーザーはこの商品にすでに応募しています")
      end
    end
  end

  describe ".by_target" do
    let(:applier) { create(:user) }
    let(:published_item) { create(:item, :with_max_five_images, :published) }
    let(:sold_item_where_applier_won) { create(:item, :with_max_five_images, :sold) }
    let(:sold_item_where_applier_lost) { create(:item, :with_max_five_images, :sold) }

    context "when target is applied" do
      it "returns applied entries" do
        applied_entry = create(:entry, item: published_item, user: applier)
        won_entry = create(:entry, :won, item: sold_item_where_applier_won, user: applier)
        lost_entry = create(:entry, :lost, item: sold_item_where_applier_lost, user: applier)

        result = described_class.by_target("applied")

        expect(result).to include(applied_entry)
        expect(result).not_to include(won_entry)
        expect(result).not_to include(lost_entry)
      end
    end

    context "when target is won" do
      it "returns won entries" do
        applied_entry = create(:entry, item: published_item, user: applier)
        won_entry = create(:entry, :won, item: sold_item_where_applier_won, user: applier)
        lost_entry = create(:entry, :lost, item: sold_item_where_applier_lost, user: applier)
        result = described_class.by_target("won")

        expect(result).to include(won_entry)
        expect(result).not_to include(applied_entry)
        expect(result).not_to include(lost_entry)
      end
    end

    context "when target is lost" do
      it "returns lost entries" do
        applied_entry = create(:entry, item: published_item, user: applier)
        won_entry = create(:entry, :won, item: sold_item_where_applier_won, user: applier)
        lost_entry = create(:entry, :lost, item: sold_item_where_applier_lost, user: applier)
        result = described_class.by_target("lost")

        expect(result).to include(lost_entry)
        expect(result).not_to include(applied_entry)
        expect(result).not_to include(won_entry)
      end
    end

    context "when target is invalid" do
      it "returns all entries" do
        applied_entry = create(:entry, item: published_item, user: applier)
        won_entry = create(:entry, :won, item: sold_item_where_applier_won, user: applier)
        lost_entry = create(:entry, :lost, item: sold_item_where_applier_lost, user: applier)
        result = described_class.by_target("invalid_status")

        expect(result).to include(applied_entry)
        expect(result).to include(won_entry)
        expect(result).to include(lost_entry)
      end
    end
  end

  describe "#cannot_apply_for_own_item" do
    let(:item) { create(:item, :with_max_five_images, :published, user: seller) }
    let(:entry) { build(:entry, item: item, user: seller) }

    it "validates applying for own item" do
      is_valid = entry.valid?
      expect(is_valid).to be false
      expect(entry.errors.full_messages).to include("自分の出品物には応募できません")
    end
  end

  describe "#cannot_apply_for_expired_item" do
    let(:item) { create(:item, :with_max_five_images, :published, user: seller, entry_deadline_at: entry_deadline_at) }
    let(:applier) { create(:user) }

    context "when applying for item whose deadline was yesterday" do
      let(:entry_deadline_at) { Date.yesterday.end_of_day }
      let(:entry) { build(:entry, item: item, user: applier) }

      it "validates applying for expired item" do
        is_valid = entry.valid?
        expect(is_valid).to be false
        expect(entry.errors.full_messages).to include("締切の過ぎた商品には応募できません")
      end
    end

    context "when applying for item whose deadline is today" do
      let(:entry_deadline_at) { Date.today.end_of_day }
      let(:entry) { build(:entry, item: item, user: applier) }

      it "can apply for unexpired item" do
        is_valid = entry.valid?
        expect(is_valid).to be true
        expect(entry.errors.full_messages).to be_empty
      end
    end
  end

  describe "#cannot_apply_for_closed_item" do
    let(:item) { create(:item, :with_max_five_images, :closed, user: seller) }
    let(:applier) { create(:user) }
    let(:entry) { build(:entry, item: item, user: applier) }

    it "validates applying for closed item" do
      is_valid = entry.valid?
      expect(is_valid).to be false
      expect(entry.errors.full_messages).to include("公開終了した商品には応募できません")
    end
  end
end
