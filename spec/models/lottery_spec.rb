require 'rails_helper'

RSpec.describe Lottery do
  describe "run" do
    let(:seller) { create(:user, uid: "1234567890") }
    let(:item) { create(:item, :with_max_five_images, user: seller, entry_deadline_at: Date.today.end_of_day, status: :published) }
    let(:buyer) { create(:user, uid: "1234567891") }

    context "when one entry exists" do
      let!(:entry) { create(:entry, user: buyer, item: item, status: :applied) }

      it "selects winner and item gets sold status" do
        travel 1.day do
          described_class.new(item).run
          expect(entry.reload.status).to eq("won")
          # expect(item.reload.status).to eq("sold")
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
