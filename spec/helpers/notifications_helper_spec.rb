require 'rails_helper'

RSpec.describe NotificationsHelper, type: :helper do
  describe ".build_strategy" do
    context "when notifiable is comment" do
      let(:item) { create(:item, :published) }
      let(:comment) { create(:comment, item: item) }
      let(:notification) { create(:notification, :for_comment, notifiable: comment) }

      it "returns new comment notification message" do
        expect(resolve_message(notification)).to include("についてコメントしました。")
        expect(resolve_redirect_path(notification)).to eq(item_path(item))
      end
    end

    context "when notifiable is won entry" do
      let(:item) { create(:item, :sold) }
      let(:won_entry) { create(:entry, :won, item: item) }
      let(:notification) { create(:notification, :for_entry, notifiable: won_entry) }

      it "returns won notification message" do
        expect(resolve_message(notification)).to include("購入が確定しました")
        expect(resolve_redirect_path(notification)).to eq(conversation_messages_path(item))
      end
    end

    context "when notifiable is lost entry" do
      let(:item) { create(:item, :sold) }
      let(:lost_entry) { create(:entry, :lost, item: item) }
      let(:notification) { create(:notification, :for_entry, notifiable: lost_entry) }

      it "returns lost notification message" do
        expect(resolve_message(notification)).to include("落選しました")
        expect(resolve_redirect_path(notification)).to eq(item_path(item))
      end
    end

    context "when notifiable is sold item" do
      let(:item) { create(:item, :sold) }
      let(:notification) { create(:notification, :for_item, notifiable: item) }

      it "returns sold notification message" do
        expect(resolve_message(notification)).to include("購入者が決まりました")
        expect(resolve_redirect_path(notification)).to eq(conversation_messages_path(item))
      end
    end

    context "when notifiable is closed item" do
      let(:item) { create(:item, :closed) }
      let(:notification) { create(:notification, :for_item, notifiable: item) }

      it "returns closed notification message" do
        expect(resolve_message(notification)).to include("公開終了しました")
        expect(resolve_redirect_path(notification)).to eq(item_path(item))
      end
    end

    context "when notifiable is message" do
      let(:item) { create(:item) }
      let(:message) { create(:message, item: item) }
      let(:notification) { create(:notification, :for_message, notifiable: message) }

      it "returns notification message" do
        expect(resolve_message(notification)).to include("メッセージが届きました")
        expect(resolve_redirect_path(notification)).to eq(conversation_messages_path(item))
      end
    end
  end
end
