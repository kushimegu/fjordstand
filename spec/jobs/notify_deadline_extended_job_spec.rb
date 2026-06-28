require 'rails_helper'

RSpec.describe NotifyDeadlineExtendedJob, type: :job do
  let!(:webhook) { stub_discord_webhook }

  let(:seller) { create(:user) }
  let(:item) { create(:item, :published, user: seller) }
  let(:applicant) { create(:user) }

  before do
    create(:entry, item: item, user: applicant)
  end

  describe '#perform_later' do
    it "sends webhook notification" do
      NotifyDeadlineExtendedJob.perform_now(item.id)
      expect(webhook).to have_received(:notify_item_deadline_extended).with([ applicant ], item)
    end
  end
end
