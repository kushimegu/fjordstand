require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:seller) { create(:user) }
  let(:buyer) { create(:user) }

  let!(:sold_item) { create(:item, user: seller, status: :sold) }
  let!(:closed_item) { create(:item, user: seller, status: :closed) }
  let!(:entry) { create(:entry, user: buyer, item: sold_item, status: :won) }

  describe ".unread" do
    it "returns only unread notification" do
      unread_notification = create(:notification, :for_item, user: seller, notifiable: sold_item)
      read_notification = create(:notification, :for_item, user: seller, notifiable: closed_item, read: true)
      result = described_class.unread

      expect(result).to include(unread_notification)
      expect(result).not_to include(read_notification)
    end
  end

  describe ".by_target" do
    context "when target is unread" do
      it "returns unread notifications" do
        unread_notification = create(:notification, :for_item, user: seller, notifiable: sold_item)
        read_notification = create(:notification, :for_item, user: seller, notifiable: closed_item, read: true)
        result = described_class.by_target("unread")

        expect(result).to include(unread_notification)
        expect(result).not_to include(read_notification)
      end
    end

    context "when target is invalid" do
      it "returns all notifications" do
        unread_notification = create(:notification, :for_item, user: seller, notifiable: sold_item)
        read_notification = create(:notification, :for_item, user: seller, notifiable: closed_item, read: true)
        result = described_class.by_target("invalid_status")

        expect(result).to include(unread_notification)
        expect(result).to include(read_notification)
      end
    end
  end

  describe "#message" do
    context "when notifiable is message" do
      it "returns notification message" do
        message = create(:message, user: buyer, item: sold_item)
        notification = seller.notifications.last

        expect(notification.message).to include("メッセージが届きました")
      end
    end

    context "when notifiable is won entry" do
      it "returns won notification message" do
        notification = create(:notification, :for_entry, notifiable: entry, user: buyer)

        expect(notification.message).to include("当選しました")
      end
    end

    context "when notifiable is lost entry" do
      it "returns lost notification message" do
        loser = create(:user)
        lost_entry = create(:entry, user: loser, item: sold_item, status: :lost)
        notification = create(:notification, :for_entry, notifiable: lost_entry, user: loser)

        expect(notification.message).to include("落選しました")
      end
    end

    context "when notifiable is sold item" do
      it "returns sold notification message" do
        notification = create(:notification, :for_item, notifiable: sold_item, user: seller)

        expect(notification.message).to include("当選者が決まりました")
      end
    end

    context "when notifiable is closed item" do
      it "returns closed notification message" do
        notification = create(:notification, :for_item, notifiable: closed_item, user: seller)

        expect(notification.message).to include("公開終了しました")
      end
    end
  end

  describe "#link" do
    context "when notifiable is message" do
      it "returns link to messages" do
        message = create(:message, user: buyer, item: sold_item)
        notification = seller.notifications.last

        expect(notification.link).to eq("/transactions/#{sold_item.id}/messages")
      end
    end

    context "when notifiable is won entry" do
      it "returns link to messages" do
        notification = create(:notification, :for_entry, notifiable: entry, user: buyer)

        expect(notification.link).to eq("/transactions/#{sold_item.id}/messages")
      end
    end

    context "when notifiable is lost entry" do
      it "returns link to item" do
        loser = create(:user, uid: "3")
        lost_entry = create(:entry, user: loser, item: sold_item, status: :lost)
        notification = create(:notification, :for_entry, notifiable: lost_entry, user: loser)

        expect(notification.link).to eq("/items/#{sold_item.id}")
      end
    end

    context "when notifiable is sold item" do
      it "returns link to message" do
        notification = create(:notification, :for_item, notifiable: sold_item, user: seller)

        expect(notification.link).to eq("/transactions/#{sold_item.id}/messages")
      end
    end

    context "when notifiable is closed item" do
      it "returns link to item" do
        notification = create(:notification, :for_item, notifiable: closed_item, user: seller)

        expect(notification.link).to eq("/items/#{closed_item.id}")
      end
    end
  end
end
