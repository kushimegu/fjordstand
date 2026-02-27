require 'rails_helper'

RSpec.describe "Items", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:selenium_chrome_headless)

    webhook_double = instance_double(DiscordWebhook, notify_item_published: true, notify_item_closed: true)
    allow(DiscordWebhook).to receive(:new).and_return(webhook_double)
    login(user)
  end

  describe "listings tab switching" do
    it "shows published items when published tab is clicked" do
      published_item = create(:item, :with_max_five_images, :published, user: user)
      closed_item = create(:item, :with_max_five_images, :closed, user: user)
      sold_item = create(:item, :with_max_five_images, :sold, user: user)
      visit listings_path
      click_on "出品中"

      expect(page).to have_css("a.active-tab", text: "出品中")
      expect(page).to have_content("#{published_item.title}")
      expect(page).not_to have_content("#{closed_item.title}")
      expect(page).not_to have_content("#{sold_item.title}")
    end

    it "shows sold items when sold tab is clicked" do
      published_item = create(:item, :with_max_five_images, :published, user: user)
      closed_item = create(:item, :with_max_five_images, :closed, user: user)
      sold_item = create(:item, :with_max_five_images, :sold, user: user)
      visit listings_path
      click_on "抽選済み"

      expect(page).to have_css("a.active-tab", text: "抽選済み")
      expect(page).not_to have_content("#{published_item.title}")
      expect(page).not_to have_content("#{closed_item.title}")
      expect(page).to have_content("#{sold_item.title}")
    end

    it "shows closed items when closed tab is clicked" do
      published_item = create(:item, :with_max_five_images, :published, user: user)
      closed_item = create(:item, :with_max_five_images, :closed, user: user)
      sold_item = create(:item, :with_max_five_images, :sold, user: user)
      visit listings_path
      click_on "公開終了"

      expect(page).to have_css("a.active-tab", text: "公開終了")
      expect(page).not_to have_content("#{published_item.title}")
      expect(page).to have_content("#{closed_item.title}")
      expect(page).not_to have_content("#{sold_item.title}")
    end

    it "shows all items when all tab is clicked" do
      published_item = create(:item, :with_max_five_images, :published, user: user)
      closed_item = create(:item, :with_max_five_images, :closed, user: user)
      sold_item = create(:item, :with_max_five_images, :sold, user: user)
      visit listings_path
      click_on "全て"

      expect(page).to have_css("a.active-tab", text: "全て")
      expect(page).to have_content("#{published_item.title}")
      expect(page).to have_content("#{closed_item.title}")
      expect(page).to have_content("#{sold_item.title}")
    end
  end

  describe "change big item image" do
    let(:item) { create(:item, :with_three_images, :published, user: user) }

    it "changes big image to the thumbnail image when clicked" do
      visit item_path(item)
      expect(page).to have_selector(".thumbnail")
      all(".thumbnail")[1].click
      expect(page).to have_selector("#big-image[src*='book2.png']")
    end

    it "changes to next image when next button is clicked" do
      visit item_path(item)
      expect(page).to have_selector("#big-image[src*='book1.png']")
      expect(page).to have_selector("#next")
      click_button("next")
      expect(page).to have_selector("#big-image[src*='book2.png']")
    end

    it "changes to prev image when prev button is clicked" do
      visit item_path(item)
      expect(page).to have_selector("#big-image[src*='book1.png']")
      expect(page).to have_selector("#prev")
      click_button("prev")
      expect(page).to have_selector("#big-image[src*='book3.png']")
    end
  end

  describe "save item" do
    context "when save item as draft" do
      it "shows on draft index page" do
        click_on '出品する'
        fill_in '商品名', with: '技術書'
        click_on '下書きに保存する'

        expect(page).to have_current_path(drafts_path)
        expect(page).to have_content('技術書')
      end
    end

    context "when save item as published" do
      it "shows item on item page" do
        click_on '出品する'

        fill_in '商品名', with: '技術書'
        attach_file '商品画像', "#{Rails.root}/spec/fixtures/files/book1.png"
        fill_in '価格', with: 1000
        select '出品者', from: '送料負担'
        fill_in 'お支払い方法', with: 'PayPay'
        fill_in '購入希望申請締切', with: Date.tomorrow
        click_button '出品する'

        expect(page).to have_content('技術書')
      end
    end
  end

  describe "update item" do
    context "when close published item" do
      it "shows item on listings page" do
        item = create(:item, :with_max_five_images, :published, user: user, title: '技術書')
        visit item_path(item)
        click_on '編集する'

        click_on '出品を取り下げる'
        expect(page).to have_current_path(listings_path)
        expect(page).to have_content('技術書')
      end
    end

    context "when update draft as draft" do
      it "shows item on draft index page" do
        create(:item, :with_max_five_images, user: user, title: '技術書')

        visit drafts_path
        click_on '技術書'
        fill_in '商品名', with: '小説'
        click_on '上書き保存する'

        expect(page).to have_current_path(drafts_path)
        expect(page).to have_content('小説')
      end
    end

    context "when update draft as published item" do
      it "shows item on item index page" do
        item = create(:item, :with_max_five_images, user: user, title: '技術書')

        visit drafts_path
        click_on '技術書'
        fill_in '商品名', with: '小説'
        click_button '出品する'

        expect(page).to have_current_path(item_path(item))
        expect(page).to have_content('小説')
      end
    end

    context "when update published item" do
      it "shows item on item index page" do
        item = create(:item, :with_max_five_images, :published, user: user, title: '技術書セット')

        visit item_path(item)
        click_on '編集する'
        fill_in "item[title_append]", with: '3冊'
        click_on '更新する'

        expect(page).to have_current_path(item_path(item))
        expect(page).to have_content('技術書セット 3冊')
      end
    end
  end

  describe "delete item" do
    context "when deleting draft" do
      it "deletes item and redirects to drafts index" do
        create(:item, user: user, title: '技術書')
        visit drafts_path
        click_on '技術書'
        click_on '削除する'

        expect(page).to have_current_path(drafts_path)
        expect(page).not_to have_content('技術書')
        expect(page).to have_content('下書きを削除しました')
      end
    end

    context "when deleting published item" do
      it "deletes item and redirects to items index" do
        create(:item, :with_max_five_images, :published, user: user, title: '技術書')
        visit items_path
        click_on '技術書'
        click_on '削除する'

        expect(page).to have_current_path(items_path)
        expect(page).not_to have_content('技術書')
        expect(page).to have_content('商品を削除しました')
      end
    end
  end
end
