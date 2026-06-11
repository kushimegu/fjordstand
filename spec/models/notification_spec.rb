require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:user) { create(:user) }

  describe ".unread" do
    let!(:unread_notification) { create(:notification, :for_item, user: user) }

    before { create(:notification, :for_item, :read, user: user) }

    it "returns only unread notification" do
      expect(Notification.unread).to contain_exactly(unread_notification)
    end
  end

  describe ".by_target" do
    let!(:unread_notification) { create(:notification, :for_item, user: user) }
    let!(:read_notification) { create(:notification, :for_item, :read, user: user) }

    context "when target is unread" do
      it "returns unread notifications" do
        expect(Notification.by_target("unread")).to contain_exactly(unread_notification)
      end
    end

    context "when target is invalid" do
      it "returns all notifications" do
        expect(Notification.by_target("invalid_status")).to contain_exactly(unread_notification, read_notification)
      end
    end
  end

  describe "#message" do
    context "when notifiable is message" do
      let(:notification) { create(:notification, :for_message, user: user) }

      it "returns notification message" do
        expect(notification.message).to include("メッセージが届きました")
      end
    end

    context "when notifiable is won entry" do
      let(:won_entry) { create(:entry, :won, user: user) }
      let(:notification) { create(:notification, :for_entry, notifiable: won_entry, user: user) }

      it "returns won notification message" do
        expect(notification.message).to include("購入が確定しました")
      end
    end

    context "when notifiable is lost entry" do
      let(:lost_entry) { create(:entry, :lost, user: user) }
      let(:notification) { create(:notification, :for_entry, notifiable: lost_entry, user: user) }

      it "returns lost notification message" do
        expect(notification.message).to include("落選しました")
      end
    end

    context "when notifiable is sold item" do
      let(:sold_item) { create(:item, :sold, user: user) }
      let(:notification) { create(:notification, :for_item, notifiable: sold_item, user: user) }

      it "returns sold notification message" do
        expect(notification.message).to include("購入者が決まりました")
      end
    end

    context "when notifiable is closed item" do
      let(:closed_item) { create(:item, :closed, user: user) }
      let(:notification) { create(:notification, :for_item, notifiable: closed_item, user: user) }

      it "returns closed notification message" do
        expect(notification.message).to include("公開終了しました")
      end
    end

    context "when notifiable is comment" do
      let(:comment) { create(:comment, user: user) }
      let(:notification) { create(:notification, :for_comment, notifiable: comment, user: user) }

      it "returns new comment notification message" do
        expect(notification.message).to include("についてコメントしました。")
      end
    end
  end

  describe "#link" do
    let(:seller) { create(:user) }
    let(:sold_item) { create(:item, :sold, user: seller) }

    context "when notifiable is message" do
      let(:notification) { create(:notification, :for_message, user: user, notifiable: create(:message, item: sold_item)) }

      it "returns link to messages" do
        expect(notification.link).to eq("/conversations/#{sold_item.id}/messages")
      end
    end

    context "when notifiable is won entry" do
      let(:won_entry) { create(:entry, :won, item: sold_item, user: user) }
      let(:notification) { create(:notification, :for_entry, notifiable: won_entry, user: user) }

      it "returns link to messages" do
        expect(notification.link).to eq("/conversations/#{sold_item.id}/messages")
      end
    end

    context "when notifiable is lost entry" do
      let(:lost_entry) { create(:entry, item: sold_item, user: user) }
      let(:notification) { create(:notification, :for_entry, notifiable: lost_entry, user: user) }

      it "returns link to item" do
        expect(notification.link).to eq("/items/#{sold_item.id}")
      end
    end

    context "when notifiable is sold item" do
      let(:notification) { create(:notification, :for_item, notifiable: sold_item, user: user) }

      it "returns link to message" do
        expect(notification.link).to eq("/conversations/#{sold_item.id}/messages")
      end
    end

    context "when notifiable is closed item" do
      let(:closed_item) { create(:item, :closed) }
      let(:notification) { create(:notification, :for_item, notifiable: closed_item, user: user) }

      it "returns link to item" do
        expect(notification.link).to eq("/items/#{closed_item.id}")
      end
    end

    context "when notifiable is comment" do
      let(:comment) { create(:comment, item: sold_item) }
      let(:notification) { create(:notification, :for_comment, notifiable: comment, user: user) }

      it "returns link to item" do
        expect(notification.link).to eq("/items/#{sold_item.id}")
      end
    end
  end
end
