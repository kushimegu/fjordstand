require 'rails_helper'

RSpec.describe "Entries", type: :system do
  let(:user) { create(:user) }
  let(:item) { create(:item, :with_max_five_images, :published) }

  before do
    driven_by(:selenium_chrome_headless)

    webhook_double = instance_double(DiscordWebhook, notify_item_published: true)
    allow(DiscordWebhook).to receive(:new).and_return(webhook_double)
    login(user)
  end

  describe "watch item" do
    it "can create watch when button is clicked" do
      visit item_path(item)
      find("a[href='#{item_watches_path(item)}']").click

      expect(page).to have_content("コメント欄をWatchしました")
    end
  end

  describe "cancel item watch" do
    it "can cancel watch when button is clicked" do
      create(:watch, user: user, item: item)

      visit item_path(item)
      find("a[href='#{item_watches_path(item)}']").click

      expect(page).to have_content("コメント欄のWatchを外しました")
    end
  end
end
