require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:seller) { create(:user, uid: "1") }
  let(:buyer) { create(:user, uid: "2") }
  let(:loser) { create(:user, uid: "3")}

  let!(:sold_item) { create(:item, user: seller, status: :sold) }
  let!(:closed_item) { create(:item, user: seller, status: :closed)}
  let!(:entry) { create(:entry, user: buyer, item: sold_item, status: :won)}
  
  describe "scopes" do
    let!(:unread_notification) { create(:notification, :for_item, user: seller, notifiable: sold_item, read: false)}
    let!(:read_notification) { create(:notification, :for_item, user: seller, notifiable: closed_item, read: true)}

    describe ".unread" do
      it "returns only unread notification" do
        result = Notification.unread

        expect(result).to include(unread_notification)
        expect(result).to_not include(read_notification)
      end
    end

    describe ".by_target" do
      context "when target is unread" do
        it "returns unread notifications" do
          result = Notification.by_target("unread")

          expect(result).to include(unread_notification)
          expect(result).to_not include(read_notification)
        end
      end

      context "when target is invalid" do
        it "returns all notifications" do
          result = Notification.by_target("invalid_status")

          expect(result).to include(unread_notification)
          expect(result).to include(read_notification)
        end
      end
    end
  end

  describe "#message" do
    context "when notifiable is Message" do
      it "returns message notification" do
        message = create(:message, user: buyer, item: sold_item)

        expect(seller.notifications.last.message).to include("メッセージが届きました")
      end
    end

    context "when notifiable is Entry" do
      context "when entry won" do
        it "returns won message notification" do
          notification = create(:notification, :for_entry, notifiable: entry, user: buyer)

          expect(notification.message).to include("当選しました")
        end
      end

      context "when entry lost" do
        it "returns lost message notification" do
          lost_entry = create(:entry, user: loser, item: sold_item, status: :lost)
          notification = create(:notification, :for_entry, notifiable: lost_entry, user: loser)

          expect(notification.message).to include("落選しました")
        end
      end
    end

    context "when notifiable is Item" do
      context "when item was sold" do
        it "returns sold message notification" do
          notification = create(:notification, :for_item, notifiable: sold_item, user: seller)

          expect(notification.message).to include("当選者が決まりました")
        end
      end

      context "when item was closed" do
        it "returns closed message notification" do
          notification = create(:notification, :for_item, notifiable: closed_item, user: seller)

          expect(notification.message).to include("公開終了しました")
        end
      end
    end
  end

  describe "#link" do
    context "when notifiable is Message" do
      it "returns link to messages" do
        message = create(:message, user: buyer, item: sold_item)

        expect(seller.notifications.last.link).to eq("/transactions/#{sold_item.id}/messages")
      end
    end

    context "when notifiable is Entry" do
      context "when entry won" do
        it "returns link to messages" do
          notification = create(:notification, :for_entry, notifiable: entry, user: buyer)

          expect(notification.link).to eq("/transactions/#{sold_item.id}/messages")
        end
      end

      context "when entry lost" do
        it "returns link to item" do
          lost_entry = create(:entry, user: loser, item: sold_item, status: :lost)
          notification = create(:notification, :for_entry, notifiable: lost_entry, user: loser)
          
          expect(notification.link).to eq("/items/#{sold_item.id}")
        end
      end
    end
    
    context "when notifiable is Item" do
      context "when item is sold" do
        it "returns link to message" do
          notification = create(:notification, :for_item, notifiable: sold_item, user: seller)

          expect(notification.link).to eq("/transactions/#{sold_item.id}/messages")
        end
      end

      context "when item is closed" do
        it "returns link to item" do
          notification = create(:notification, :for_item, notifiable: closed_item, user: seller)

          expect(notification.link).to eq("/items/#{closed_item.id}")
        end
      end
    end
  end
end
