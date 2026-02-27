require 'rails_helper'

RSpec.describe "Messages", type: :system do
  let(:webhook_double) { instance_double(DiscordWebhook, notify_item_published: true, notify_new_message: true) }

  let(:seller) { create(:user) }
  let(:buyer) { create(:user) }
  let(:item) { create(:item, :with_max_five_images, :published, user: seller) }

  before do
    driven_by(:selenium_chrome_headless)

    allow(DiscordWebhook).to receive(:new).and_return(webhook_double)
  end

  describe "send messages" do
    context "when authorized user is logged in" do
      it "can send message" do
        create(:entry, :won, item: item, user: buyer)

        login(buyer)
        expect(page).to have_current_path(items_path)
        visit transaction_messages_path(item)

        fill_in "message_body", with: "こんにちは"
        click_on "送信する"

        expect(page).to have_content("こんにちは")
      end
    end

    context "when unauthorized user is logged in" do
      let(:other_user) { create(:user) }

      it "cannot access to messages index page" do
        login(other_user)
        expect(page).to have_current_path(items_path)
        visit transaction_messages_path(item)

        expect(page).to have_current_path(items_path)
        expect(page).to have_content("この連絡ページを閲覧する権限がありません")
      end
    end

    context "when message contains only whitespace" do
      it "is invalid" do
        create(:entry, :won, item: item, user: buyer)

        login(seller)
        expect(page).to have_current_path(items_path)
        visit transaction_messages_path(item)

        fill_in "message_body", with: "\n"
        click_on "送信する"

        expect(page).to have_content("メッセージを入力してください")
      end
    end
  end
end
