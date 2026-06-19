require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:item) { create(:item, :published) }
  let(:user) { create(:user) }

  before do
    without_partial_double_verification do
      allow(helper).to receive(:current_user).and_return(user)
    end
  end

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
    context "when from watches" do
      before { controller.params = { from: "watches" } }

      it "returns link to watches" do
        expect(helper.back_link_for_item(item)).to include("Watch中一覧へ", watches_path)
      end
    end

    context "when from entries" do
      before { controller.params = { from: "entries" } }

      it "returns link to entries" do
        expect(helper.back_link_for_item(item)).to include("希望商品一覧へ", entries_path)
      end
    end

    context "when from listings" do
      before { controller.params = { from: "listings" } }

      it "returns link to listings" do
        expect(helper.back_link_for_item(item)).to include("自分の出品一覧へ", listings_path)
      end
    end

    context "when from messages" do
      before { controller.params = { from: "messages" } }

      it "returns link to messages" do
        expect(helper.back_link_for_item(item)).to include("連絡ページへ", conversation_messages_path(item))
      end
    end

    context "when from notifications" do
      it "returns link to items" do
        expect(helper.back_link_for_item(item)).to include("販売中一覧へ", items_path)
      end
    end
  end

  describe "#active_items_tab?" do
    context "when current page is conversations path and includes from=notifications" do
      before do
        allow(controller.request).to receive(:path).and_return("/conversations")
        controller.params = { from: "notifications" }
      end

      it "returns false" do
        expect(helper.active_items_tab?).to be false
      end
    end

    context "when current page is items_path" do
      before { allow(helper).to receive(:current_page?) { |path| path == items_path } }

      it "returns true" do
        expect(helper.active_items_tab?).to be true
      end
    end

    context "when current page is watches_path" do
      before { allow(helper).to receive(:current_page?) { |path| path == watches_path } }

      it "returns true" do
        expect(helper.active_items_tab?).to be true
      end
    end

    context "when fullpath includes from=watches" do
      before { controller.params = { from: "watches" } }

      it "returns true" do
        expect(helper.active_items_tab?).to be true
      end
    end

    context "when fullpath includes from=items" do
      before { controller.params = { from: "items" } }

      it "returns true" do
        expect(helper.active_items_tab?).to be true
      end
    end

    context "when fullpath includes from=notifications" do
      before { controller.params = { from: "notifications" } }

      it "returns true" do
        expect(helper.active_items_tab?).to be true
      end
    end

    context "when current page is other path and fullpath does not include from param" do
      before { allow(helper).to receive(:current_page?) { |path| path == item_path(item) } }

      it "returns false" do
        expect(helper.active_items_tab?).to be false
      end
    end
  end

  describe "#active_entries_tab?" do
    context "when current page is entries_path" do
      before { allow(helper).to receive(:current_page?) { |path| path == entries_path } }

      it "returns true" do
        expect(helper.active_entries_tab?).to be true
      end
    end

    context "when fullpath includes from=entries" do
      before { controller.params = { from: "entries" } }

      it "returns true" do
        expect(helper.active_entries_tab?).to be true
      end
    end

    context "when current page is other path and fullpath does not include from=entries" do
      before { allow(helper).to receive(:current_page?) { |path| path == item_path(item) } }

      it "returns false" do
        expect(helper.active_entries_tab?).to be false
      end
    end
  end

  describe "#active_listings_tab?" do
    let(:item) { create(:item, user: user) }

    context "when page is items show and is not from messages" do
      before do
        allow(helper).to receive(:controller_name).and_return("items")
        allow(helper).to receive(:action_name).and_return("show")
        controller.params = { from: "watches" }
        assign(:item, item)
      end

      it "returns true" do
        expect(helper.active_listings_tab?).to be true
      end
    end

    context "when page is items edit" do
      before do
        allow(helper).to receive(:controller_name).and_return("items")
        allow(helper).to receive(:action_name).and_return("edit")
        assign(:item, item)
      end

      it "returns true" do
        expect(helper.active_listings_tab?).to be true
      end
    end

    context "when page is items show and is from messages" do
      before do
        assign(:item, item)
        allow(controller.request).to receive(:fullpath).and_return("/items#{item.id}?from=messages")
      end

      it "returns false" do
        expect(helper.active_listings_tab?).to be false
      end
    end

    context "when current page is new_item_path" do
      before { allow(helper).to receive(:current_page?) { |path| path == new_item_path } }

      it "returns true" do
        expect(helper.active_listings_tab?).to be true
      end
    end

    context "when current page is listings_path" do
      before { allow(helper).to receive(:current_page?) { |path| path == listings_path } }

      it "returns true" do
        expect(helper.active_listings_tab?).to be true
      end
    end

    context "when fullpath includes from=listings" do
      before { controller.params = { from: "listings" } }

      it "returns true" do
        expect(helper.active_listings_tab?).to be true
      end
    end

    context "when current page is other path and fullpath does not include from=listings" do
      before { allow(helper).to receive(:current_page?) { |path| path == entries_path } }

      it "returns false" do
        expect(helper.active_listings_tab?).to be false
      end
    end
  end

  describe "#active_conversations_tab?" do
    context "when current page is conversations_path" do
      before { allow(controller.request).to receive(:path).and_return("/conversations") }

      it "returns true" do
        expect(helper.active_conversations_tab?).to be true
      end
    end

    context "when fullpath includes from=messages" do
      before { controller.params = { from: "messages" } }

      it "returns true" do
        expect(helper.active_conversations_tab?).to be true
      end
    end

    context "when current page is other path and fullpath does not include from=messages" do
      before { allow(controller.request).to receive(:path).and_return("/item/#{item.id}") }

      it "returns false" do
        expect(helper.active_conversations_tab?).to be false
      end
    end
  end
end
