require 'rails_helper'

RSpec.describe "Notifications", type: :system do
  let(:user) { create(:user) }

  let!(:closed_item) { create(:item, :with_max_five_images, user: user, status: :closed) }
  let!(:sold_item) { create(:item, :with_max_five_images, user: user, status: :sold) }

  before do
    driven_by(:selenium_chrome_headless)

    login(user)
  end

  describe "notification icon link" do
    context "when unread notification exists" do
      it "has link to unread notification tab" do
        create(:notification, :for_item, user: user, notifiable: closed_item)

        visit items_path

        expect(page).to have_css("a[href='#{notifications_path(status: "unread")}']")
      end
    end

    context "when no unread notification exists" do
      it "has link to all notification tab" do
        create(:notification, :for_item, user: user, notifiable: closed_item, read: true)

        visit items_path

        expect(page).to have_css("a[href='#{notifications_path}']")
      end
    end
  end

  describe "making notification read" do
    context "when making one notification read" do
      it "redirects to notification link and decreases unread count by 1" do
        notification_for_closed_item = create(:notification, :for_item, user: user, notifiable: closed_item)
        create(:notification, :for_item, user: user, notifiable: sold_item)

        expect(page).to have_current_path(items_path)

        visit notifications_path(status: "unread")
        expect(page).to have_css("span.absolute", text: "2")

        find("a[href='#{read_notification_path(notification_for_closed_item)}']").click

        expect(page).to have_current_path(item_path(closed_item))
        expect(page).to have_css("span.absolute", text: "1")
      end
    end

    context "when making all notifications read" do
      it "redirects to all notification tab and unread count would not show" do
        create(:notification, :for_item, user: user, notifiable: closed_item)
        create(:notification, :for_item, user: user, notifiable: sold_item)

        expect(page).to have_current_path(items_path)

        visit notifications_path(status: "unread")
        expect(page).to have_css("span.absolute", text: "2")

        click_on "全て既読にする"

        expect(page).to have_current_path(notifications_path)
        expect(page).not_to have_css("span.absolute")
      end
    end
  end

  describe "notification count" do
    context "when over 99 notifications exists" do
      it "shows 99+ count on notification icon" do
        create_list(:notification, 100, :for_item, user: user)

        visit items_path
        expect(page).to have_css("span.absolute", text: "99+")
      end
    end

    context "when no notifications exists" do
      it "shows no count on notification icon" do
        expect(page).to have_current_path(items_path)

        visit notifications_path

        expect(page).not_to have_css("span.absolute")
        expect(page).to have_content("通知はありません")
      end
    end
  end

  describe "notification tab switching" do
    it "shows unread notifications when unread tab is clicked" do
      create(:notification, :for_item, user: user, notifiable: closed_item)
      create(:notification, :for_item, user: user, notifiable: sold_item, read: true)

      visit notifications_path
      click_on "未読"
      expect(page).to have_css("a.border-b-2", text: "未読")
      expect(page).to have_content("「#{closed_item.title}」は当選者なしで公開終了しました。")
      expect(page).not_to have_content("「#{sold_item.title}」の抽選が完了し、当選者が決まりました。")
    end

    it "shows all notifications when all tab is clicked" do
      create(:notification, :for_item, user: user, notifiable: closed_item)
      create(:notification, :for_item, user: user, notifiable: sold_item, read: true)

      visit notifications_path(status: "unread")
      click_on "全て", exact: true
      expect(page).to have_css("a.border-b-2", text: "全て")
      expect(page).to have_content("「#{closed_item.title}」は当選者なしで公開終了しました。")
      expect(page).to have_content("「#{sold_item.title}」の抽選が完了し、当選者が決まりました。")
    end
  end
end
