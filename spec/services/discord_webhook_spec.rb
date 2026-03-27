require 'rails_helper'

RSpec.describe DiscordWebhook, discord_stub: false do
  let(:seller) { create(:user) }

  let(:client) { instance_double(Discordrb::Webhooks::Client) }
  let(:builder) { instance_double(Discordrb::Webhooks::Builder) }

  before do
    allow(Discordrb::Webhooks::Client).to receive(:new).and_return(client)

    allow(builder).to receive(:content=)
    allow(builder).to receive(:add_embed)
    allow(client).to receive(:execute).and_yield(builder)
  end

  describe "#notify_item_published" do
    let(:item) { create(:item, user: seller) }

    it "sends webhook notification" do
      webhook = described_class.new
      webhook.notify_item_published(item)

      expect(builder).to have_received(:content=)
        .with("🛒新しい商品が出品されました！")
    end
  end

  describe "#notify_item_closed" do
    let(:item) { create(:item, :closed, user: seller) }

    it "sends webhook notification" do
      webhook = described_class.new
      webhook.notify_item_closed([], item)

      expect(builder).to have_received(:content=).with("\n📢出品が取り下げられました")
    end
  end

  describe "#notify_item_deadline_extended" do
    let(:item) { create(:item, :published, user: seller) }

    it "sends webhook notification" do
      webhook = described_class.new
      webhook.notify_item_deadline_extended([], item)

      expect(builder).to have_received(:content=).with("\n⏰購入希望申込期限が延長されました")
    end
  end

  describe "#notify_lottery_completed" do
    let(:applicant) { create(:user) }
    let(:item) { create(:item, :published, user: seller, winner: applicant) }

    it "sends webhook notification" do
      webhook = described_class.new
      webhook.notify_lottery_completed([ applicant, seller ], item)

      expect(builder).to have_received(:content=).with("<@#{applicant.uid}> <@#{seller.uid}>\n🎉抽選が完了し#{applicant.name}さんが当選しました！")
    end
  end

  describe "#notify_lottery_skipped" do
    let(:item) { create(:item, :published, user: seller) }

    it "sends webhook notification" do
      webhook = described_class.new
      webhook.notify_lottery_skipped([ seller ], item)

      expect(builder).to have_received(:content=).with("<@#{seller.uid}>\n⏭️希望者がいなかったため当選者なしで公開終了しました")
    end
  end

  describe "#notify_new_comment" do
    let(:item) { create(:item, :published, user: seller) }

    it "sends webhook notification" do
      webhook = described_class.new
      webhook.notify_new_comment([ seller ], item)

      expect(builder).to have_received(:content=).with("<@#{seller.uid}>\n📝新しいコメントがつきました")
    end
  end

  describe "#notify_new_message" do
    let(:item) { create(:item, :published, user: seller) }

    it "sends webhook notification" do
      webhook = described_class.new
      webhook.notify_new_message([ seller ], item)

      expect(builder).to have_received(:content=).with("<@#{seller.uid}>\n💬新しいメッセージが届きました")
    end
  end
end
