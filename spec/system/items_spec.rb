require 'rails_helper'

RSpec.describe "Items", type: :system do
  let(:user) { create(:user, uid: "1234567890") }

  before do
    driven_by(:selenium_chrome_headless)

    login(user)
  end

  describe "change big item image" do
    let(:item) { create(:item, :with_three_images, :published, user: user) }

    it "changes big image to the thumbnail image when clicked" do
      visit item_path(item)
      expect(page).to have_selector(".thumbnail")
      all(".thumbnail")[1].click
      expect(page).to have_selector("#big-image[src*='test2.png']")
    end

    it "changes to next image when next button is clicked" do
      visit item_path(item)
      expect(page).to have_selector("#big-image[src*='test1.png']")
      expect(page).to have_selector("#next")
      click_button("next")
      expect(page).to have_selector("#big-image[src*='test2.png']")
    end

    it "changes to prev image when prev button is clicked" do
      visit item_path(item)
      expect(page).to have_selector("#big-image[src*='test1.png']")
      expect(page).to have_selector("#prev")
      click_button("prev")
      expect(page).to have_selector("#big-image[src*='test3.png']")
    end
  end

  describe "save item" do
    context "when save item as draft" do
      before do
        click_on '出品する'
        fill_in '商品名', with: '技術書'
        click_on '下書きに保存する'
      end

      it "shows on draft index page" do
        visit drafts_path
        expect(page).to have_content('技術書')
      end

      it "does not show on item index page" do
        visit items_path
        expect(page).not_to have_content('技術書')
      end
    end
  end
end
