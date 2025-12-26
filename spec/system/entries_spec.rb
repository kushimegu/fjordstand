require 'rails_helper'

RSpec.describe "Entries", type: :system do
  let(:user) { create(:user) }
  let(:published_item) { create(:item, :with_max_five_images, :published) }
  let(:sold_item_where_user_won) { create(:item, :with_max_five_images, :sold) }
  let(:sold_item_where_user_lost) { create(:item, :with_max_five_images, :sold) }

  before do
    driven_by(:selenium_chrome_headless)

    login(user)
  end

  describe "apply for item" do
    it "can make entry when button is clicked" do
      visit item_path(published_item)
      click_on "購入希望を申請する"
      expect(page).to have_content("購入希望を申請しました")
      expect(page).to have_content("購入希望を出しています")
      expect(page).to have_button("購入希望を取り消す")
    end
  end

  describe "cancel entry for item" do
    it "can cancel entry when button is clicked" do
      create(:entry, user: user, item: published_item)

      visit item_path(published_item)
      click_on "購入希望を取り消す"

      expect(page).to have_content("購入希望を取り消しました")
      expect(page).not_to have_content("購入希望を申請しました")
      expect(page).to have_button("購入希望を申請する")
    end
  end

  describe "entries tab switching" do
    it "shows applied entries when applied tab is clicked" do
      applied_entry = create(:entry, item: published_item, user: user)
      won_entry = create(:entry, :won, item: sold_item_where_user_won, user: user)
      lost_entry = create(:entry, :lost, item: sold_item_where_user_lost, user: user)

      visit entries_path
      click_on "希望中"
      expect(page).to have_css("a.active-tab", text: "希望中")
      expect(page).to have_content("#{applied_entry.item.title}")
      expect(page).not_to have_content("#{won_entry.item.title}")
      expect(page).not_to have_content("#{lost_entry.item.title}")
    end

    it "shows won entries when won tab is clicked" do
      applied_entry = create(:entry, item: published_item, user: user)
      won_entry = create(:entry, :won, item: sold_item_where_user_won, user: user)
      lost_entry = create(:entry, :lost, item: sold_item_where_user_lost, user: user)

      visit entries_path
      click_on "当選"
      expect(page).to have_css("a.active-tab", text: "当選")
      expect(page).to have_content("#{won_entry.item.title}")
      expect(page).not_to have_content("#{applied_entry.item.title}")
      expect(page).not_to have_content("#{lost_entry.item.title}")
    end

    it "shows lost entries when lost tab is clicked" do
      applied_entry = create(:entry, item: published_item, user: user)
      won_entry = create(:entry, :won, item: sold_item_where_user_won, user: user)
      lost_entry = create(:entry, :lost, item: sold_item_where_user_lost, user: user)

      visit entries_path
      click_on "落選"
      expect(page).to have_css("a.active-tab", text: "落選")
      expect(page).to have_content("#{lost_entry.item.title}")
      expect(page).not_to have_content("#{won_entry.item.title}")
      expect(page).not_to have_content("#{applied_entry.item.title}")
    end

    it "shows all notifications when all tab is clicked" do
      applied_entry = create(:entry, item: published_item, user: user)
      won_entry = create(:entry, :won, item: sold_item_where_user_won, user: user)
      lost_entry = create(:entry, :lost, item: sold_item_where_user_lost, user: user)

      visit entries_path
      click_on "全て"
      expect(page).to have_css("a.active-tab", text: "全て")
      expect(page).to have_content("#{lost_entry.item.title}")
      expect(page).to have_content("#{won_entry.item.title}")
      expect(page).to have_content("#{applied_entry.item.title}")
    end
  end
end
