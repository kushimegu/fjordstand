require 'rails_helper'

RSpec.describe "Entries", type: :system do
  let(:user) { create(:user) }
  let(:item) { create(:item, :published) }

  before do
    driven_by(:selenium_chrome_headless)

    login(user)
  end

  describe "apply for item" do
    it "can make entry when button is clicked" do
      expect(page).to have_current_path(items_path)

      visit item_path(item)
      click_on "購入希望を申請する"

      expect(page).to have_content("購入希望を申請しました")
      expect(page).to have_content("購入希望を出しています")
      expect(page).to have_content("応募人数\n1人")
      expect(page).to have_button("購入希望を取り消す")
    end
  end

  describe "cancel entry for item" do
    it "can cancel entry when button is clicked" do
      create(:entry, user: user, item: item)
      expect(page).to have_current_path(items_path)

      visit item_path(item)
      click_on "購入希望を取り消す"

      expect(page).to have_content("購入希望を取り消しました")
      expect(page).not_to have_content("購入希望を申請しました")
      expect(page).to have_button("購入希望を申請する")
    end
  end

  describe "entries tab switching" do
    let!(:applied_entry) { create(:entry, user: user) }
    let!(:won_entry) { create(:entry, :won, user: user) }
    let!(:lost_entry) { create(:entry, :lost, user: user) }

    it "shows applied entries when applied tab is clicked" do
      expect(page).to have_current_path(items_path)

      visit entries_path
      click_on "購入希望"
      expect(page).to have_css("a.active-tab", text: "購入希望")
      expect(page).to have_content("#{applied_entry.item.title}")
      expect(page).not_to have_content("#{won_entry.item.title}")
      expect(page).not_to have_content("#{lost_entry.item.title}")
    end

    it "shows won entries when won tab is clicked" do
      expect(page).to have_current_path(items_path)

      visit entries_path
      click_on "購入確定"
      expect(page).to have_css("a.active-tab", text: "購入確定")
      expect(page).to have_content("#{won_entry.item.title}")
      expect(page).not_to have_content("#{applied_entry.item.title}")
      expect(page).not_to have_content("#{lost_entry.item.title}")
    end

    it "shows lost entries when lost tab is clicked" do
      expect(page).to have_current_path(items_path)

      visit entries_path
      click_on "落選"
      expect(page).to have_css("a.active-tab", text: "落選")
      expect(page).to have_content("#{lost_entry.item.title}")
      expect(page).not_to have_content("#{won_entry.item.title}")
      expect(page).not_to have_content("#{applied_entry.item.title}")
    end

    it "shows all notifications when all tab is clicked" do
      expect(page).to have_current_path(items_path)

      visit entries_path
      click_on "全て"
      expect(page).to have_css("a.active-tab", text: "全て")
      expect(page).to have_content("#{lost_entry.item.title}")
      expect(page).to have_content("#{won_entry.item.title}")
      expect(page).to have_content("#{applied_entry.item.title}")
    end
  end
end
