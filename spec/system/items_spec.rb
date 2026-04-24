require 'rails_helper'

RSpec.describe "Items", type: :system do
  let(:user) { create(:user, :admin) }

  before { driven_by(:selenium_chrome_headless) }

  describe "listings tab switching" do
    before { login(user) }

    it "shows published items when published tab is clicked" do
      published_item = create(:item, :published, user: user)
      closed_item = create(:item, :closed, user: user)
      sold_item = create(:item, :sold, user: user)
      expect(page).to have_current_path(items_path)

      visit listings_path
      click_on "出品中"

      expect(page).to have_css("a.active-tab", text: "出品中")
      expect(page).to have_content("#{published_item.title}")
      expect(page).not_to have_content("#{closed_item.title}")
      expect(page).not_to have_content("#{sold_item.title}")
    end

    it "shows sold items when sold tab is clicked" do
      published_item = create(:item, :published, user: user)
      closed_item = create(:item, :closed, user: user)
      sold_item = create(:item, :sold, user: user)
      expect(page).to have_current_path(items_path)

      visit listings_path
      click_on "購入者決定"

      expect(page).to have_css("a.active-tab", text: "購入者\n決定")
      expect(page).not_to have_content("#{published_item.title}")
      expect(page).not_to have_content("#{closed_item.title}")
      expect(page).to have_content("#{sold_item.title}")
    end

    it "shows closed items when closed tab is clicked" do
      published_item = create(:item, :published, user: user)
      closed_item = create(:item, :closed, user: user)
      sold_item = create(:item, :sold, user: user)
      expect(page).to have_current_path(items_path)

      visit listings_path
      click_on "公開終了"

      expect(page).to have_css("a.active-tab", text: "公開\n終了")
      expect(page).not_to have_content("#{published_item.title}")
      expect(page).to have_content("#{closed_item.title}")
      expect(page).not_to have_content("#{sold_item.title}")
    end

    it "shows all items when all tab is clicked" do
      published_item = create(:item, :published, user: user)
      closed_item = create(:item, :closed, user: user)
      sold_item = create(:item, :sold, user: user)
      expect(page).to have_current_path(items_path)

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

    before { login(user) }

    it "changes big image to the thumbnail image when clicked" do
      expect(page).to have_current_path(items_path)

      visit item_path(item)
      expect(page).to have_selector(".thumbnail")
      all(".thumbnail")[1].click
      expect(page).to have_selector("#big-image[src*='book2.png']")
    end

    it "changes to next image when next button is clicked" do
      expect(page).to have_current_path(items_path)

      visit item_path(item)
      expect(page).to have_selector("#big-image[src*='book1.png']")
      expect(page).to have_selector("#next")
      click_button("next")
      expect(page).to have_selector("#big-image[src*='book2.png']")
    end

    it "changes to prev image when prev button is clicked" do
      expect(page).to have_current_path(items_path)

      visit item_path(item)
      expect(page).to have_selector("#big-image[src*='book1.png']")
      expect(page).to have_selector("#prev")
      click_button("prev")
      expect(page).to have_selector("#big-image[src*='book3.png']")
    end
  end

  describe "save item" do
    before { login(user) }

    context "when save item as draft" do
      it "shows on draft index page" do
        expect(page).to have_current_path(items_path)

        click_on '出品する'
        fill_in '商品名', with: '技術書'
        click_on '下書きとして保存する'

        expect(page).to have_current_path(listings_path)
        expect(page).to have_content('技術書')
      end
    end

    context "when save item as published" do
      it "shows item on item page" do
        expect(page).to have_current_path(items_path)

        click_on '出品する'
        fill_in '商品名', with: '技術書'
        attach_file "item[images][]", "#{Rails.root}/spec/fixtures/files/book1.png", make_visible: true, match: :first
        fill_in '価格', with: 1000
        choose '出品者'
        fill_in 'お支払い方法', with: 'PayPay'
        fill_in '購入希望申請締切', with: Date.tomorrow
        click_button '出品する'

        expect(page).to have_content('技術書')
      end
    end
  end

  describe "update item" do
    before { login(user) }

    context "when item is sold" do
      it "is not editable" do
        item = create(:item, :sold, user: user)
        buyer = create(:user)
        create(:entry, :won, item: item, user: buyer)
        expect(page).to have_current_path(items_path)

        visit item_path(item)
        expect(page).not_to have_content('編集する')
      end
    end

    context "when close published item" do
      it "shows item on listings page" do
        item = create(:item, :published, user: user, title: '技術書')
        expect(page).to have_current_path(items_path)

        visit item_path(item)
        click_on '編集する'

        click_on '出品を取り下げる'
        expect(page).to have_current_path(listings_path)
        expect(page).to have_content('技術書')
      end
    end

    context "when update draft as draft" do
      it "shows item on draft index page" do
        create(:item, user: user, title: '技術書')
        expect(page).to have_current_path(items_path)

        visit listings_path
        click_on '技術書'
        fill_in '商品名', with: '小説'
        click_on '上書き保存する'

        expect(page).to have_current_path(listings_path)
        expect(page).to have_content('小説')
      end
    end

    context "when update draft as published item" do
      it "shows item on item index page" do
        item = create(:item, :with_item_image, user: user, title: '技術書')
        expect(page).to have_current_path(items_path)

        visit listings_path
        click_on '技術書'
        fill_in '商品名', with: '小説'
        click_button '出品する'

        expect(page).to have_current_path(item_path(item))
        expect(page).to have_content('小説')
      end
    end

    context "when update published item" do
      it "shows item on item index page" do
        item = create(:item, :published, :with_item_image, user: user, title: '技術書セット')

        expect(page).to have_current_path(items_path)
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
      before { login(user) }

      it "deletes item and redirects to listings index" do
        create(:item, user: user, title: '技術書')
        expect(page).to have_current_path(items_path)

        visit listings_path
        click_on '技術書'
        accept_confirm do
          click_on '削除する'
        end

        expect(page).to have_current_path(listings_path)
        expect(page).not_to have_content('技術書')
        expect(page).to have_content('下書きを削除しました')
      end
    end

    context "when deleting published item" do
      let(:admin) { create(:user, :admin, uid: "123") }

      before { login(admin) }

      it "deletes item and redirects to items index" do
        create(:item, :published, user: user, title: '技術書')
        expect(page).to have_current_path(items_path)

        visit items_path
        click_on '技術書'
        expect(page).to have_content('削除する')
        accept_confirm do
          click_on '削除する'
        end

        expect(page).to have_current_path(items_path)
        expect(page).not_to have_content('技術書')
        expect(page).to have_content('商品を削除しました')
      end
    end
  end
end
