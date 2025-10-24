require 'rails_helper'

RSpec.describe "Items", type: :system do
  let(:user) { create(:user, uid: "1234567890") }
  let(:item) { create(:item, :with_three_images) }

  before do
    driven_by(:selenium_chrome_headless)

    login(user)
  end

  it "changes big image to the thumbnail image when clicked" do
    visit item_path(item)
    expect(page).to have_selector(".thumbnail")
    all(".thumbnail")[1].click
    expect(page).to have_selector("#big-image[src*='test2.png']")
  end

  it "changes to next image when next button is clicked" do
    visit item_path(item)
    expect(page).to have_selector("#big-image[src*='test1.png']")
    expect(page). to have_selector("#next")
    find("#next").click
    expect(page).to have_selector("#big-image[src*='test2.png']")
  end

  it "changes to prev image when prev button is clicked" do
    visit item_path(item)
    expect(page).to have_selector("#big-image[src*='test1.png']")
    expect(page). to have_selector("#prev")
    find("#prev").click
    expect(page).to have_selector("#big-image[src*='test3.png']")
  end
end
