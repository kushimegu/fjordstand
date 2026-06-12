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
        expect(result).to include(conversation_messages_path(item))
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

  describe "#active_items_tab?" do
    context "when current page is items_path" do
      before do
        allow(helper).to receive(:current_page?) { |path| path == items_path }
        allow(helper).to receive(:request).and_return(double(fullpath: items_path))
      end

      it "returns true" do
        expect(helper.active_items_tab?).to be true
      end
    end

    context "when current page is watches_path" do
      before do
        allow(helper).to receive(:current_page?) { |path| path == watches_path }
        allow(helper).to receive(:request).and_return(double(fullpath: watches_path))
      end

      it "returns true" do
        expect(helper.active_items_tab?).to be true
      end
    end

    context "when fullpath includes from=watches" do
      before do
        allow(helper).to receive_messages(
          current_page?: false,
          request: double(fullpath: "/items/1?from=watches", path: "/items/1")
        )
      end

      it "returns true" do
        expect(helper.active_items_tab?).to be true
      end
    end

    context "when fullpath includes from=items" do
      before do
        allow(helper).to receive_messages(
          current_page?: false,
          request: double(fullpath: "/items/1?from=items", path: "/items/1")
        )
      end

      it "returns true" do
        expect(helper.active_items_tab?).to be true
      end
    end

    context "when fullpath includes from=notifications" do
      before do
        allow(helper).to receive_messages(
          current_page?: false,
          request: double(fullpath: "/items/1?from=notifications", path: "/items/1")
        )
      end

      it "returns true" do
        expect(helper.active_items_tab?).to be true
      end
    end

    context "when current page is other path and fullpath does not include from param" do
      before do
        allow(helper).to receive_messages(
          current_page?: false,
          request: double(fullpath: "/listings")
        )
      end

      it "returns false" do
        expect(helper.active_items_tab?).to be false
      end
    end
  end

  describe "#active_entries_tab?" do
    context "when current page is entries_path" do
      before do
        allow(helper).to receive(:current_page?) { |path| path == entries_path }
        allow(helper).to receive(:request).and_return(double(fullpath: entries_path))
      end

      it "returns true" do
        expect(helper.active_entries_tab?).to be true
      end
    end

    context "when fullpath includes from=entries" do
      before do
        allow(helper).to receive_messages(
          current_page?: false,
          request: double(fullpath: "/items/1?from=entries", path: "/items/1")
        )
      end

      it "returns true" do
        expect(helper.active_entries_tab?).to be true
      end
    end

    context "when current page is other path and fullpath does not include from=entries" do
      before do
        allow(helper).to receive_messages(
          current_page?: false,
          request: double(fullpath: "/listings")
        )
      end

      it "returns false" do
        expect(helper.active_entries_tab?).to be false
      end
    end
  end

  describe "#active_listings_tab?" do
    context "when current page is new_item_path" do
      before do
        allow(helper).to receive(:current_page?) { |path| path == new_item_path }
        allow(helper).to receive(:request).and_return(double(fullpath: new_item_path))
      end

      it "returns true" do
        expect(helper.active_listings_tab?).to be true
      end
    end

    context "when current page is listings_path" do
      before do
        allow(helper).to receive(:current_page?) { |path| path == listings_path }
        allow(helper).to receive(:request).and_return(double(fullpath: listings_path))
      end

      it "returns true" do
        expect(helper.active_listings_tab?).to be true
      end
    end

    context "when current page is edit item path" do
      let(:item) { create(:item) }

      before do
        allow(helper).to receive_messages(
          current_page?: false,
          request: double(path: "/items/#{item.id}/edit")
        )
      end

      it "returns true" do
        expect(helper.active_listings_tab?).to be true
      end
    end

    context "when fullpath includes from=listings" do
      before do
        allow(helper).to receive_messages(
          current_page?: false,
          request: double(fullpath: "/items/1/edit?from=listings", path: "/items/1/edit")
        )
      end

      it "returns true" do
        expect(helper.active_listings_tab?).to be true
      end
    end

    context "when current page is other path and fullpath does not include from=listings" do
      before do
        allow(helper).to receive_messages(
          current_page?: false,
          request: double(fullpath: "/items/1?from=entries", path: "/items/1")
        )
      end

      it "returns false" do
        expect(helper.active_listings_tab?).to be false
      end
    end
  end

  describe "#active_conversations_tab?" do
    context "when current page is conversations_path" do
      before do
        allow(helper).to receive_messages(
          current_page?: true,
          request: double(fullpath: conversations_path, path: conversations_path)
        )
      end

      it "returns true" do
        expect(helper.active_conversations_tab?).to be true
      end
    end

    context "when fullpath includes from=messages" do
      before do
        allow(helper).to receive_messages(
          current_page?: false,
          request: double(fullpath: "/items/1?from=messages", path: "/items/1")
        )
      end

      it "returns true" do
        expect(helper.active_conversations_tab?).to be true
      end
    end

    context "when current page is other path and fullpath does not include from=messages" do
      before do
        allow(helper).to receive_messages(
          current_page?: false,
          request: double(fullpath: "/listings", path: "/listings")
        )
      end

      it "returns false" do
        expect(helper.active_conversations_tab?).to be false
      end
    end
  end
end
