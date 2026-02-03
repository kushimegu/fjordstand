require 'rails_helper'

RSpec.describe Lottery do
  let(:webhook_double) { instance_double(DiscordWebhook, notify_lottery_completed: true, notify_lottery_skipped: true) }

  before do
    allow(DiscordWebhook).to receive(:new).and_return(webhook_double)
  end

  describe "run" do
    let(:seller) { create(:user) }
    let!(:item) { create(:item, :with_max_five_images, :published, user: seller, entry_deadline_at: Date.today.end_of_day) }
    let(:buyer) { create(:user) }

    context "when one entry exists" do
      let!(:entry) { create(:entry, user: buyer, item: item) }

      it "selects winner and item gets sold status" do
        travel 1.day do
          described_class.new(item).run
          expect(entry.reload.status).to eq("won")
          expect(item.reload.status).to eq("sold")
        end
      end
    end

    context "when no entry exists" do
      it "does not select winner and item gets closed status" do
        travel 1.day do
          described_class.new(item).run
          expect(item.reload.status).to eq("closed")
        end
      end
    end
  end
end
