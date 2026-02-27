require 'rails_helper'
require 'webmock/rspec'

RSpec.describe "DiscordWebhooks" do
  let(:seller) { create(:user) }
  let(:client) { instance_double(Discordrb::Webhooks::Client) }

  before do
    allow(Discordrb::Webhooks::Client).to receive(:new).and_return(client)
    allow(client).to receive(:execute) do |&block|
      builder = instance_double(Discordrb::Webhooks::Builder)
      allow(builder).to receive(:content=)
      allow(builder).to receive(:add_embed)
      block.call(builder) if block
    end
  end

  describe "#notify_item_published" do
    let(:item) { create(:item, :with_max_five_images, user: seller) }

    before do
      allow(client).to receive(:execute) do |&block|
        builder = instance_double(Discordrb::Webhooks::Builder)
        allow(builder).to receive(:content=).with("🛒新しい商品が出品されました！")
        allow(builder).to receive(:add_embed)
        block.call(builder) if block
      end
    end

    context "when item is published" do
      it "sends webhook notification" do
        item.update!(status: :published)
        expect(client).to have_received(:execute)
      end
    end
  end

  describe "#notify_item_closed" do
    let(:item) { create(:item, :with_max_five_images, user: seller) }

    before do
      allow(item).to receive(:notify_publishing)
      item.update!(status: :published)

      allow(client).to receive(:execute) do |&block|
        builder = instance_double(Discordrb::Webhooks::Builder)
        allow(builder).to receive(:content=).with("\n📢出品が取り下げられました")
        allow(builder).to receive(:add_embed)
        block.call(builder) if block
      end
    end

    context "when item is closed by user" do
      it "sends webhook notification" do
        item.close!(by: :user)
        expect(client).to have_received(:execute)
      end
    end
  end

  describe "#notify_item_deadline_extended" do
    let(:item) { create(:item, :with_max_five_images, user: seller, entry_deadline_at: Date.current + 5.days) }

    before do
      allow(item).to receive(:notify_publishing)
      item.update!(status: :published)

      allow(client).to receive(:execute) do |&block|
        builder = instance_double(Discordrb::Webhooks::Builder)
        allow(builder).to receive(:content=).with("\n⏰購入希望申込期限が延長されました")
        allow(builder).to receive(:add_embed)
        block.call(builder) if block
      end
    end

    context "when item entry deadline is extended" do
      it "sends webhook notification" do
        item.update!(entry_deadline_at: Date.current + 7.days)
        expect(client).to have_received(:execute)
      end
    end
  end

  describe "#notify_lottery_completed" do
    let(:item) { create(:item, :with_max_five_images, user: seller) }
    let(:applicant) { create(:user) }

    before do
      allow(item).to receive(:notify_publishing)
      item.update!(status: :published)

      create(:entry, user: applicant, item: item)
      allow(client).to receive(:execute) do |&block|
        builder = instance_double(Discordrb::Webhooks::Builder)
        allow(builder).to receive(:content=).with("<@#{applicant.uid}> <@#{seller.uid}>\n🎉抽選が完了し#{applicant.name}さんが当選しました！")
        allow(builder).to receive(:add_embed)
        block.call(builder) if block
      end
    end

    context "when lottery is completed" do
      it "sends webhook notification" do
        Lottery.new(item).run
        expect(client).to have_received(:execute)
      end
    end
  end

  describe "#notify_lottery_skipped" do
    let(:item) { create(:item, :with_max_five_images, user: seller) }

    before do
      allow(item).to receive(:notify_publishing)
      item.update!(status: :published)

      allow(client).to receive(:execute) do |&block|
        builder = instance_double(Discordrb::Webhooks::Builder)
        allow(builder).to receive(:content=).with("<@#{seller.uid}>\n⏭️希望者がいなかったため当選者なしで公開終了しました")
        allow(builder).to receive(:add_embed)
        block.call(builder) if block
      end
    end

    context "when lottery was skipped" do
      it "sends webhook notification" do
        Lottery.new(item).run
        expect(client).to have_received(:execute)
      end
    end
  end

  describe "#notify_new_comment" do
    let(:item) { create(:item, :with_max_five_images, user: seller) }
    let(:commentator) { create(:user) }

    before do
      allow(item).to receive(:notify_publishing)
      item.update!(status: :published)

      allow(client).to receive(:execute) do |&block|
        builder = instance_double(Discordrb::Webhooks::Builder)
        allow(builder).to receive(:content=).with("<@#{seller.uid}>\n📝新しいコメントがつきました")
        allow(builder).to receive(:add_embed)
        block.call(builder) if block
      end
    end

    context "when comment was created" do
      it "sends webhook notification" do
        create(:comment, user: commentator, item: item)
        expect(client).to have_received(:execute)
      end
    end
  end

  describe "#notify_new_message" do
    let(:item) { create(:item, :with_max_five_images, :sold, user: seller) }
    let(:buyer) { create(:user) }

    before do
      create(:entry, :won, user: buyer, item: item)
      allow(client).to receive(:execute) do |&block|
        builder = instance_double(Discordrb::Webhooks::Builder)
        allow(builder).to receive(:content=).with("<@#{seller.uid}>\n💬新しいメッセージが届きました")
        allow(builder).to receive(:add_embed)
        block.call(builder) if block
      end
    end

    context "when message was created" do
      it "sends webhook notification" do
        create(:message, user: buyer, item: item)
        expect(client).to have_received(:execute)
      end
    end
  end
end
