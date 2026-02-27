require 'rails_helper'

RSpec.describe "Items", type: :system do
  let(:webhook_double) { instance_double(DiscordWebhook, notify_new_comment: true) }

  let(:user) { create(:user) }
  let(:item) { create(:item, user: user) }

  before do
    driven_by(:selenium_chrome_headless)

    allow(DiscordWebhook).to receive(:new).and_return(webhook_double)

    login(user)
  end

  describe "create comment" do
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
end
