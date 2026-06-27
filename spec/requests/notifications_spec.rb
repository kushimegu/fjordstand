require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  let(:user) { create(:user) }
  let(:buyer) { create(:user) }

  before { login(user) }

  describe "GET /index" do
    context "when notifications exists" do
      let(:users_item) { create(:item, :closed, title: "小説") }
      let(:buyers_item) { create(:item, :closed, title: "参考書") }

      it "returns current users notifications with http success" do
        users_notification = create(:notification, :for_item, notifiable: users_item, user: user)
        others_notification = create(:notification, :for_item, notifiable: buyers_item, user: buyer)

        get notifications_path

        expect(response).to have_http_status(:success)

        expect(response.body).to include("「小説」は当選者なしで公開終了しました。")
        expect(response.body).not_to include("「参考書」は当選者なしで公開終了しました。")
      end
    end

    context "when no notifications exist" do
      it "returns message with http success" do
        get notifications_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("通知はありません")
      end
    end

    context "when filtering by unread status" do
      let(:book) { create(:item, :closed, title: "本") }
      let(:shoes) { create(:item, :closed, title: "靴") }

      it "returns unread notifications" do
        unread_notification = create(:notification, :for_item, notifiable: book, user: user)
        read_notification = create(:notification, :read, :for_item, notifiable: shoes, user: user)

        get notifications_path(status: "unread")

        expect(response).to have_http_status(:success)

        expect(response.body).to include("「本」は当選者なしで公開終了しました。")
        expect(response.body).not_to include("「靴」は当選者なしで公開終了しました。")
      end
    end

    context "when filtering by invalid status" do
      let(:book) { create(:item, :closed, title: "本") }
      let(:shoes) { create(:item, :closed, title: "靴") }

      it "returns all notifications" do
        unread_notification = create(:notification, :for_item, notifiable: book, user: user)
        read_notification = create(:notification, :read, :for_item, notifiable: shoes, user: user)

        get notifications_path(status: "invalid_status")

        expect(response).to have_http_status(:success)

        expect(response.body).to include("「本」は当選者なしで公開終了しました。", "「靴」は当選者なしで公開終了しました。")
      end
    end
  end
end
