require 'rails_helper'

RSpec.describe "Items", type: :system do
  let(:user) { create(:user, :admin) }

  before { driven_by(:selenium_chrome_headless) }

  describe "listings tab switching" do
    before { login(user) }

    it "shows draft items when draft tab is clicked" do
      draft_item = create(:item, user: user)
      published_item = create(:item, :published, user: user)
      closed_item = create(:item, :closed, user: user)
      sold_item = create(:item, :sold, user: user)

      expect(page).to have_current_path(items_path)

      visit listings_path
      click_on "下書き"

      expect(page).to have_css("a.active-tab", text: "下書き")
      expect(page).to have_content("#{draft_item.title}")
      expect(page).not_to have_content("#{published_item.title}")
      expect(page).not_to have_content("#{closed_item.title}")
      expect(page).not_to have_content("#{sold_item.title}")
    end

    it "shows published items when published tab is clicked" do
      draft_item = create(:item, user: user)
      published_item = create(:item, :published, user: user)
      closed_item = create(:item, :closed, user: user)
      sold_item = create(:item, :sold, user: user)
      expect(page).to have_current_path(items_path)

      visit listings_path
      click_on "出品中"

      expect(page).to have_css("a.active-tab", text: "出品中")
      expect(page).not_to have_content("#{draft_item.title}")
      expect(page).to have_content("#{published_item.title}")
      expect(page).not_to have_content("#{closed_item.title}")
      expect(page).not_to have_content("#{sold_item.title}")
    end

    it "shows sold items when sold tab is clicked" do
      draft_item = create(:item, user: user)
      published_item = create(:item, :published, user: user)
      closed_item = create(:item, :closed, user: user)
      sold_item = create(:item, :sold, user: user)
      expect(page).to have_current_path(items_path)

      visit listings_path
      click_on "購入者決定"

      expect(page).to have_css("a.active-tab", text: "購入者\n決定")
      expect(page).not_to have_content("#{draft_item.title}")
      expect(page).not_to have_content("#{published_item.title}")
      expect(page).not_to have_content("#{closed_item.title}")
      expect(page).to have_content("#{sold_item.title}")
    end

    it "shows closed items when closed tab is clicked" do
      draft_item = create(:item, user: user)
      published_item = create(:item, :published, user: user)
      closed_item = create(:item, :closed, user: user)
      sold_item = create(:item, :sold, user: user)
      expect(page).to have_current_path(items_path)

      visit listings_path
      click_on "公開終了"

      expect(page).to have_css("a.active-tab", text: "公開\n終了")
      expect(page).not_to have_content("#{draft_item.title}")
      expect(page).not_to have_content("#{published_item.title}")
      expect(page).to have_content("#{closed_item.title}")
      expect(page).not_to have_content("#{sold_item.title}")
    end

    it "shows all items when all tab is clicked" do
      draft_item = create(:item, user: user)
      published_item = create(:item, :published, user: user)
      closed_item = create(:item, :closed, user: user)
      sold_item = create(:item, :sold, user: user)
      expect(page).to have_current_path(items_path)

      visit listings_path
      click_on "全て"

      expect(page).to have_css("a.active-tab", text: "全て")
      expect(page).to have_content("#{draft_item.title}")
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

  describe "item images preview" do
    before { login(user) }

    context "when multiple images are attached collectively" do
      it "shows all image previews and remaining slots" do
        expect(page).to have_current_path(items_path)
        click_on '出品する'

        images = (1..3).map { |i| Rails.root.join("spec/fixtures/files/book#{i}.png") }

        attach_file('まとめて追加する', images, make_visible: true)

        expect(page).to have_selector('[data-image-preview-target="savedPreview"] img', count: 3)
        expect(page).to have_selector('[data-image-preview-target="extraContainer"]:not(.hidden)', count: 2)

        click_on '下書きとして保存する'
        expect(page).to have_content('下書き保存しました')

        item = Item.last
        expect(item.images[0].filename.to_s).to eq 'book1.png'
        expect(item.images[1].filename.to_s).to eq 'book2.png'
        expect(item.images[2].filename.to_s).to eq 'book3.png'
      end
    end

    context "when images are chosen separately" do
      it "shows all image previews and remaining slots" do
        expect(page).to have_current_path(items_path)
        click_on '出品する'

        image1 = Rails.root.join("spec/fixtures/files/book1.png")
        image2 = Rails.root.join("spec/fixtures/files/book2.png")

        inputs = all('[data-image-preview-target="input"]:not([multiple]', visible: false)
        inputs[0].attach_file(image1)
        inputs[1].attach_file(image2)

        expect(page).to have_selector('[data-image-preview-target="extraContainer"]:not(.hidden)', count: 3)

        click_on '下書きとして保存する'
        expect(page).to have_content('下書き保存しました')

        item = Item.last
        expect(item.images[0].filename.to_s).to eq 'book1.png'
        expect(item.images[1].filename.to_s).to eq 'book2.png'
      end
    end

    context "when images are chosen collectively then separately" do
      it "shows all image previews and remaining slots" do
        expect(page).to have_current_path(items_path)
        click_on '出品する'

        images = (1..3).map { |i| Rails.root.join("spec/fixtures/files/book#{i}.png") }
        image =  Rails.root.join("spec/fixtures/files/book4.png")

        attach_file('まとめて追加する', images, make_visible: true)
        first('[data-image-preview-target="input"]:not([multiple])', visible: false).attach_file(image)

        expect(page).to have_selector('[data-image-preview-target="savedPreview"] img', count: 4)
        expect(page).to have_selector('[data-image-preview-target="extraContainer"]:not(.hidden)', count: 1)

        click_on '下書きとして保存する'
        expect(page).to have_content('下書き保存しました')

        item = Item.last
        expect(item.images[0].filename.to_s).to eq 'book1.png'
        expect(item.images[3].filename.to_s).to eq 'book4.png'
      end
    end

    context "when adding image separately and deleting preview" do
      it "clears input value" do
        expect(page).to have_current_path(items_path)
        click_on '出品する'

        image = Rails.root.join("spec/fixtures/files/book1.png")
        first('[data-image-preview-target="input"]:not([multiple])', visible: false).attach_file(image)

        expect(page).to have_selector('[data-image-preview-target="savedPreview"] img')

        find('[data-action="click->image-preview#removeImage"]', match: :first, visible: :all).click
        expect(page).to have_no_selector('[data-image-preview-target="savedPreview"] img')

        click_on '下書きとして保存する'
        expect(page).to have_content('下書き保存しました')

        expect(Item.last.images).to be_empty
      end
    end

    context "when deleting image from draft item" do
      it "deletes selected image" do
        item = create(:item, :with_three_images, user: user)
        expect(page).to have_current_path(items_path)
        visit edit_item_path(item)

        expect(page).to have_selector('[data-image-preview-target="savedPreview"] img', count: 3)
        all('[data-action="click->image-preview#removeImage"]')[1].click
        expect(page).to have_selector('[data-image-preview-target="savedPreview"] img', count: 2)

        click_on '下書きを更新する'
        expect(page).to have_content('下書きを更新しました')

        item.reload
        expect(item.images[0].filename.to_s).to eq 'book1.png'
        expect(item.images[1].filename.to_s).to eq 'book3.png'
      end
    end

    context "when adding image to draft item with item images" do
      it "adds image in selected order" do
        item = create(:item, :with_three_images, user: user)

        expect(page).to have_current_path(items_path)
        visit edit_item_path(item)

        image1 = Rails.root.join("spec/fixtures/files/book4.png")
        image2 = Rails.root.join("spec/fixtures/files/book5.png")

        attach_file('まとめて追加する', image1, make_visible: true)
        first('[data-image-preview-target="input"]:not([multiple])', visible: false).attach_file(image2)

        click_on '下書きを更新する'
        expect(page).to have_content('下書きを更新しました')

        item.reload
        expect(item.images[3].filename.to_s).to eq('book4.png')
        expect(item.images[4].filename.to_s).to eq('book5.png')
      end
    end

    context "when re-selecting images collectively" do
      it "changes preview to new images" do
        expect(page).to have_current_path(items_path)
        click_on '出品する'

        images = (1..3).map { |i| Rails.root.join("spec/fixtures/files/book#{i}.png") }
        attach_file "まとめて追加する", images, make_visible: true
        expect(page).to have_selector('[data-image-preview-target="savedPreview"] img', count: 3)
        expect(page).to have_content "選び直す"

        input = find('[data-image-preview-target="input"][multiple]', visible: false)
        page.execute_script(<<~JS, input)
          arguments[0].value = "";
          arguments[0].dispatchEvent(new Event('change', { bubbles: true }));
        JS
        expect(page).not_to have_selector('[data-image-preview-target="savedPreview] img')
        expect(page).to have_selector('[data-image-preview-target="extraContainer"]:not(.hidden)', count: 5)

        attach_file "まとめて追加する", [Rails.root.join("spec/fixtures/files/book4.png")], make_visible: true
        expect(page).to have_selector('[data-image-preview-target="savedPreview"] img', count: 1)
      end
    end

    context "when cancelling editing" do
      it "deletes preview information" do
        item = create(:item, :with_three_images, user: user)

        expect(page).to have_current_path(items_path)
        visit edit_item_path(item)
        image1 = Rails.root.join("spec/fixtures/files/book4.png")
        image2 = Rails.root.join("spec/fixtures/files/book5.png")
        first('[data-image-preview-target="input"]:not([multiple])', minimum: 1, visible: false).attach_file(image1)
        all('[data-image-preview-target="input"]:not([multiple])', minimum: 2, visible: false)[1].attach_file(image2)

        all('[data-action="click->image-preview#removeImage"]')[1].click
        click_on 'キャンセル'

        item.reload
        expect(item.images.length).to be 3
      end
    end

    context "when 6 images are chosen" do
      it "stops preview and clears input" do
        expect(page).to have_current_path(items_path)
        click_on '出品する'

        images = (1..6).map { |i| Rails.root.join("spec/fixtures/files/book#{i}.png") }

        page.execute_script("window.alert = function(msg) { window.alert_msg = msg; }")
        attach_file('まとめて追加する', images, make_visible: true)
        expect(page.evaluate_script("window.alert_msg")).to eq "画像は5枚までしか登録できません"

        expect(page).to have_no_selector('[data-image-preview-target="savedPreviews"] img')
        expect(page).to have_selector('[data-image-preview-target="extraContainer"]:not(.hidden)', count: 5)
      end
    end

    context "when 6th image is chosen" do
      it "stops preview and clears input" do
        item = create(:item, :with_item_image, user: user)

        expect(page).to have_current_path(items_path)
        visit edit_item_path(item)

        image = Rails.root.join("spec/fixtures/files/book2.png")
        images = (1..4).map { |i| Rails.root.join("spec/fixtures/files/book#{i + 2}.png") }

        inputs = all('[data-image-preview-target="input"]:not([multiple]', visible: false)
        inputs[0].attach_file(image)
        page.execute_script("window.alert = function(msg) { window.alert_msg = msg; }")
        attach_file('まとめて追加する', images, make_visible: true)
        expect(page.evaluate_script("window.alert_msg")).to eq "画像は5枚までしか登録できません"

        expect(page).to have_selector('[data-image-preview-target="savedPreview"] img', count: 2)
      end
    end

    context "when gif is chosen" do
      it "stops preview and clears input" do
        expect(page).to have_current_path(items_path)
        click_on '出品する'

        gif = Rails.root.join('spec/fixtures/files/book_gif.gif')
        page.execute_script("window.alert = function(msg) { window.alert_msg = msg; }")
        attach_file('まとめて追加する', gif, make_visible: true)

        expect(page.evaluate_script("window.alert_msg")).to eq "PNGまたはJPEG形式のみアップロード可能です"
        expect(page).to have_no_selector('[data-image-preview-target="savePreviews] img')
        expect(page).to have_selector('[data-image-preview-target="extraContainer"]:not(.hidden)', count: 5)
      end
    end

    context "when image bigger than 5 MB is chosen" do
      it "stops preview and clears input" do
        expect(page).to have_current_path(items_path)
        click_on '出品する'

        image = Rails.root.join('spec/fixtures/files/bigfile.jpg')

        page.execute_script("window.alert = function(msg) { window.alert_msg = msg; }")
        attach_file('まとめて追加する', image, make_visible: true)

        expect(page.evaluate_script("window.alert_msg")).to eq "5MBまでのファイルのみアップロードできます"
        expect(page).to have_no_selector('[data-image-preview-target="savePreviews] img')
        expect(page).to have_selector('[data-image-preview-target="extraContainer"]:not(.hidden)', count: 5)
      end
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
        click_on '下書きを更新する'

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
