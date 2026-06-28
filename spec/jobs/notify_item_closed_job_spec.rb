require 'rails_helper'

RSpec.describe NotifyItemClosedJob, type: :job do
  let!(:webhook) { stub_discord_webhook }

  let(:item) { create(:item) }
  let(:applicant) { create(:user) }

  describe '#perform_later' do
    it "sends discord notification" do
      NotifyItemClosedJob.perform_now(item.id, applicant.id)
      expect(webhook).to have_received(:notify_item_closed).with([ applicant ], item)
    end
  end
end
