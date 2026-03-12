require 'rails_helper'

RSpec.describe "Items", type: :system do
  let(:user) { create(:user) }
  let(:item) { create(:item, :with_max_five_images, :published, user: user) }
  let(:admin) { create(:user, :admin, uid: "123") }

  before do
    driven_by(:selenium_chrome_headless)

    webhook_double = instance_double(DiscordWebhook, notify_item_published: true, notify_new_comment: true)
    allow(DiscordWebhook).to receive(:new).and_return(webhook_double)
  end

  describe "create comment" do
    before { login(user) }

    context "when item is not coommentable" do
      let(:item) { create(:item, user: user) }

      it "does not show comment form" do
        visit item_path(item)
        expect(page).not_to have_selector("textarea#comment_body")
      end
    end

    context "when comment is valid" do
      it "sends comment" do
        visit item_path(item)
        fill_in "comment_body", with: "初版ですか？"
        click_on "送信する"

        expect(page).to have_content("初版ですか？")
      end
    end

    context "when comment contains only whitespace" do
      it "is invalid" do
        visit item_path(item)
        fill_in "comment_body", with: "\n"
        click_on "送信する"

        expect(page).to have_content("コメントを入力してください")
      end
    end
  end

  describe "delete comment" do
    before { login(admin) }

    it "destroys comment and redirects to items index" do
      create(:comment, user: admin, item: item, body: "初版ですか？")
      create(:comment, user: user, item: item, body: "そうです")

      visit item_path(item)
      within(find(".comment", text: "そうです")) do
        accept_confirm do
          click_on "削除する"
        end
      end

      expect(page).not_to have_content("そうです")
      expect(page).to have_content("初版ですか？")
    end
  end
end
