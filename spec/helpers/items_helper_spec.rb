require 'rails_helper'

RSpec.describe ItemsHelper, type: :helper do
  describe "#shipping_fee_class" do
    context "when seller" do
      it "returns css" do
        expect(shipping_fee_class("seller")).to include("text-red-400")
      end
    end

    context "when buyer" do
      it "returns css" do
        expect(shipping_fee_class("buyer")).to include("text-gray-600")
      end
    end
  end

  describe "#item_status_badge" do
    context "when draft" do
      let(:item) { create(:item) }

      it "returns text and css" do
        expect(helper.item_status_badge(item)).to include({ text: "下書き", css: "bg-gray-400" })
      end
    end

    context "when published" do
      let(:item) { create(:item, :published) }

      it "returns text and css" do
        expect(helper.item_status_badge(item)).to include({ text: "出品中", css: "bg-cyan-500" })
      end
    end

    context "when sold" do
      let(:item) { create(:item, :sold) }

      it "returns text and css" do
        expect(helper.item_status_badge(item)).to include({ text: "購入者決定", css: "bg-red-500" })
      end
    end

    context "when closed" do
      let(:item) { create(:item, :closed) }

      it "returns text and css" do
        expect(helper.item_status_badge(item)).to include({ text: "公開終了", css: "bg-gray-400" })
      end
    end
  end

  describe "#entry_status_badge" do
    let(:item) { create(:item, :published) }

    context "when applied" do
      let(:entry) { create(:entry) }

      it "returns text and css" do
        expect(helper.entry_status_badge(entry)).to include({ text: "購入希望", css: "bg-cyan-500" })
      end
    end

    context "when won" do
      let(:entry) { create(:entry, :won) }

      it "returns text and css" do
        expect(helper.entry_status_badge(entry)).to include({ text: "購入確定", css: "bg-red-500" })
      end
    end

    context "when lost" do
      let(:entry) { create(:entry, :lost) }

      it "returns text and css" do
        expect(helper.entry_status_badge(entry)).to include({ text: "落選", css: "bg-gray-400" })
      end
    end
  end
end
