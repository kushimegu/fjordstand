require 'rails_helper'

RSpec.describe "Notifications", type: :system do
  let(:user) { create(:user) }

  let!(:closed_item) { create(:item, :closed, user: user) }
  let!(:sold_item) { create(:item, :sold, user: user) }

  before do
    driven_by(:selenium_chrome_headless)

    login(user)
  end

  describe "notification icon link" do
    context "when unread notification exists" do
      before { create(:notification, :for_item, user: user, notifiable: closed_item) }

      it "has link to unread notification tab" do
        expect(page).to have_current_path(items_path)

        visit items_path

        expect(page).to have_css("a[href='#{notifications_path(status: "unread")}']")
      end
    end

    context "when no unread notification exists" do
      before { create(:notification, :for_item, :read, user: user, notifiable: closed_item) }

      it "has link to all notification tab" do
        expect(page).to have_current_path(items_path)

        visit items_path

        expect(page).to have_css("a[href='#{notifications_path}']")
      end
    end
  end

  describe "making notification read" do
    context "when making one notification read" do
      let!(:notification_for_closed_item) { create(:notification, :for_item, user: user, notifiable: closed_item) }

      before { create(:notification, :for_item, user: user, notifiable: sold_item) }

      it "redirects to notification link and decreases unread count by 1" do
        expect(page).to have_current_path(items_path)

        visit notifications_path(status: "unread")
        expect(page).to have_css(".notification-badge", text: "2")

        find("a[href='#{notification_read_path(notification_for_closed_item)}?from=notifications']").click

        expect(page).to have_current_path("#{item_path(closed_item)}?from=notifications")
        expect(page).to have_css(".notification-badge", text: "1")
      end
    end

    context "when making all notifications read" do
      before do
        create(:notification, :for_item, user: user, notifiable: closed_item)
        create(:notification, :for_item, user: user, notifiable: sold_item)
      end

      it "redirects to all notification tab and unread count would not show" do
        expect(page).to have_current_path(items_path)

        visit notifications_path(status: "unread")
        expect(page).to have_css(".notification-badge", text: "2")

        click_on "全て既読にする"

        expect(page).to have_current_path(notifications_path)
        expect(page).not_to have_css(".notification-badge")
      end
    end
  end

  describe "notification count" do
    context "when over 99 notifications exists" do
      it "shows 99+ count on notification icon" do
        create_list(:notification, 100, :for_item, user: user)
        expect(page).to have_current_path(items_path)

        visit items_path

        expect(page).to have_selector(".notification-badge", text: "99+")
      end
    end

    context "when no notifications exists" do
      it "shows no count on notification icon" do
        expect(page).to have_current_path(items_path)

        visit notifications_path

        expect(page).not_to have_css(".notification-badge")
        expect(page).to have_content("通知はありません")
      end
    end
  end

  describe "notification tab switching" do
    before do
      create(:notification, :for_item, user: user, notifiable: closed_item)
      create(:notification, :for_item, :read, user: user, notifiable: sold_item)
    end

    it "shows unread notifications when unread tab is clicked" do
      expect(page).to have_current_path(items_path)

      visit notifications_path
      click_on "未読"

      expect(page).to have_css("a.active-tab", text: "未読")
      expect(page).to have_content("「#{closed_item.title}」は当選者なしで公開終了しました。")
      expect(page).not_to have_content("「#{sold_item.title}」の購入者が決まりました。")
    end

    it "shows all notifications when all tab is clicked" do
      expect(page).to have_current_path(items_path)

      visit notifications_path(status: "unread")
      click_on "全て", exact: true

      expect(page).to have_css("a.active-tab", text: "全て")
      expect(page).to have_content("「#{closed_item.title}」は当選者なしで公開終了しました。")
      expect(page).to have_content("「#{sold_item.title}」の購入者が決まりました。")
    end
  end
end
