require 'rails_helper'

RSpec.describe NotifyItemPublishedJob, type: :job do
  let!(:webhook) { stub_discord_webhook }

  let(:seller) { create(:user) }
  let(:item) { create(:item, user: seller) }

  describe '#perform_later' do
    it "sends webhook notification" do
      NotifyItemPublishedJob.perform_now(item.id)
      expect(webhook).to have_received(:notify_item_published).with(item)
    end
  end
end
