require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "#page_title" do
    context "when page title is empty" do
      it "returns only base title" do
        expect(helper.page_title).to eq("FjordStand")
        expect(helper.page_title("")).to eq("FjordStand")
      end
    end

    context "when page has title" do
      it "returns page title with base title" do
        expect(helper.page_title("販売中の商品")).to eq("販売中の商品 | FjordStand")
      end
    end
  end

  describe "#back_link_for_item" do
    let(:item) { create(:item) }

    context "when from watches" do
      before do
        allow(helper).to receive(:params).and_return({ from: "watches" })
      end

      it "returns link to watches" do
        result = helper.back_link_for_item(item)
        expect(result).to include("Watch中一覧へ")
        expect(result).to include(watches_path)
      end
    end

    context "when from entries" do
      before do
        allow(helper).to receive(:params).and_return({ from: "entries" })
      end

      it "returns link to entries" do
        result = helper.back_link_for_item(item)
        expect(result).to include("希望商品一覧へ")
        expect(result).to include(entries_path)
      end
    end

    context "when from listings" do
      before do
        allow(helper).to receive(:params).and_return({ from: "listings" })
      end

      it "returns link to listings" do
        result = helper.back_link_for_item(item)
        expect(result).to include("自分の出品一覧へ")
        expect(result).to include(listings_path)
      end
    end

    context "when from messages" do
      before do
        allow(helper).to receive(:params).and_return({ from: "messages" })
      end

      it "returns link to messages" do
        result = helper.back_link_for_item(item)
        expect(result).to include("連絡ページへ")
        expect(result).to include(transaction_messages_path(item))
      end
    end

    context "when from notifications" do
      it "returns link to items" do
        result = helper.back_link_for_item(item)
        expect(result).to include("販売中一覧へ")
        expect(result).to include(items_path)
      end
    end
  end
end
