require 'rails_helper'

RSpec.describe Item, type: :model do
  let(:webhook_double) { instance_double(DiscordWebhook, notify_item_published: true, notify_item_closed: true, notify_item_deadline_extended: true, notify_lottery_skipped: true) }

  before { allow(DiscordWebhook).to receive(:new).and_return(webhook_double) }

  describe "validations" do
    let(:item) { build(:item) }

    context "when content-type is invalid" do
      it "is invalid" do
        item.images.attach(
            io: File.open(Rails.root.join("spec/fixtures/files/book.txt")),
            filename: "book.txt",
            content_type: 'txt'
          )

        expect(item.valid?).to be false
        expect(item.errors[:images]).to include("のファイルタイプは許可されていません (許可されたファイルタイプはPNG, JPG)")
      end
    end

    context "when image is bigger than 5 megabytes" do
      it "is invalid" do
        item.images.attach(
            io: File.open(Rails.root.join("spec/fixtures/files/bigfile.jpg")),
            filename: "bigfile.jpg",
            content_type: 'jpg'
          )

        expect(item.valid?).to be false
        expect(item.errors[:images]).to include("のファイルサイズは5MB未満にしてください (添付ファイルのサイズは6MB)")
      end
    end

    context "when more than 5 images are attached" do
      it "is invalid" do
        6.times do |n|
          item.images.attach(
            io: File.open(Rails.root.join("spec/fixtures/files/book#{n + 1}.png")),
            filename: "book#{n + 1}.png",
            content_type: 'image/png'
          )
        end

        expect(item.valid?).to be false
        expect(item.errors[:images]).to include("には5件以下のファイルを添付してください (添付されたファイルは6件)")
      end
    end
  end

  describe "validations on publish" do
    context "when all attributes are valid" do
      let(:item) { build(:item, :with_max_five_images) }

      it "is valid" do
        expect(item.valid?(:publish)).to be true
      end
    end

    context "when title is too long" do
      let(:item) { build(:item, :with_max_five_images, title: Faker::Lorem.characters(number: 256)) }

      it "is invalid" do
        expect(item.valid?(:publish)).to be false
        expect(item.errors[:title]).to include("は255文字以内で入力してください")
      end
    end

    context "when title is blank" do
      let(:item) { build(:item, :with_max_five_images, title: nil) }

      it "is invalid" do
        expect(item.valid?(:publish)).to be false
        expect(item.errors[:title]).to include("を入力してください")
      end
    end

    context "when price is blank" do
      let(:item) { build(:item, :with_max_five_images, price: nil) }

      it "is invalid" do
        expect(item.valid?(:publish)).to be false
        expect(item.errors[:price]).to include("を入力してください")
      end
    end

    context "when payment_method is blank" do
      let(:item) { build(:item, :with_max_five_images, payment_method: nil) }

      it "is invalid" do
        expect(item.valid?(:publish)).to be false
        expect(item.errors[:payment_method]).to include("を選択してください")
      end
    end

    context "when entry_deadline_at is blank" do
      let(:item) { build(:item, :with_max_five_images, entry_deadline_at: nil) }

      it "is invalid" do
        expect(item.valid?(:publish)).to be false
        expect(item.errors[:entry_deadline_at]).to include("を入力してください")
      end
    end

    context "when image is not attached" do
      let(:item) { build(:item) }

      it "is invalid" do
        expect(item.valid?(:publish)).to be false
        expect(item.errors[:images]).to include("を1枚以上選択してください")
      end
    end
  end

  describe ".expired" do
    let(:expired_item) { create(:item, :with_max_five_images, :published, entry_deadline_at: Date.yesterday) }
    let(:unexpired_item) { create(:item, :with_max_five_images, :published, entry_deadline_at: Date.current) }

    it "returns only expired items" do
      expect(described_class.expired).to include(expired_item)
      expect(described_class.expired).not_to include(unexpired_item)
    end
  end

  describe ".by_target" do
    let(:published_item) { create(:item, :with_max_five_images, :published) }
    let(:closed_item) { create(:item, :with_max_five_images, :closed) }
    let(:sold_item) { create(:item, :with_max_five_images, :sold) }

    context "when target is published" do
      it "returns published item" do
        result = described_class.by_target("published")

        expect(result).to include(published_item)
        expect(result).not_to include(closed_item)
        expect(result).not_to include(sold_item)
      end
    end

    context "when target is closed" do
      it "returns closed item" do
        result = described_class.by_target("closed")

        expect(result).to include(closed_item)
        expect(result).not_to include(published_item)
        expect(result).not_to include(sold_item)
      end
    end

    context "when target is sold" do
      it "returns sold item" do
        result = described_class.by_target("sold")

        expect(result).to include(sold_item)
        expect(result).not_to include(published_item)
        expect(result).not_to include(closed_item)
      end
    end
  end

  describe "#other_user_for" do
    let(:seller) { create(:user) }
    let(:item) { create(:item, :with_max_five_images, :sold, user: seller) }
    let(:buyer) { create(:user) }

    context "when current user is seller" do
      it "returns buyer" do
        create(:entry, :won, item: item, user: buyer)

        expect(item.other_user_for(seller)).to eq(buyer)
      end
    end

    context "when current user is buyer" do
      it "returns seller" do
        create(:entry, :won, item: item, user: buyer)

        expect(item.other_user_for(buyer)).to eq(seller)
      end
    end
  end

  describe "#close!" do
    context "when item is closed" do
      let(:user) { create(:user) }
      let(:item) { create(:item, :with_max_five_images, :published, user: user) }

      it "changes status and clears entries" do
        item.close!(by: :user)
        expect(item.status).to eq("closed")
        expect(item.entries).to be_empty
      end
    end
  end

  describe "#deadline_today_or_later" do
    let(:item) { build(:item, :with_max_five_images, entry_deadline_at: entry_deadline_at) }

    context "when setting deadline to yesterday" do
      let(:entry_deadline_at) { Date.yesterday }

      it "validates deadline to not be earlier than today" do
        expect(item.valid?(:publish)).to be false
        expect(item.errors[:entry_deadline_at]).to include ("は本日以降に設定してください")
      end
    end

    context "when setting deadline to today" do
      let(:entry_deadline_at) { Date.current }

      it "can set deadline to today" do
        expect(item.valid?(:publish)).to be true
        expect(item.errors.full_messages).to be_empty
      end
    end

    context "when setting deadline to tomorrow" do
      let(:entry_deadline_at) { Date.tomorrow }

      it "can set deadline to tomorrow" do
        expect(item.valid?(:publish)).to be true
        expect(item.errors.full_messages).to be_empty
      end
    end
  end

  describe "#price_not_change_after_published" do
    context "when item is already published" do
      let(:item) { create(:item, :with_max_five_images, :published, price: 1000) }

      it "validates price to not change" do
        item.assign_attributes(price: 1200)

        expect(item.valid?(:publish)).to be false
        expect(item.errors[:price]).to include("は出品後に変更できません")
      end
    end

    context "when item is draft" do
      let(:item) { create(:item, price: 1000) }

      it "allows price change" do
        item.assign_attributes(price: 1200)

        expect(item.valid?).to be true
        expect(item.errors.full_messages).to be_empty
      end
    end
  end

  describe "#deadline_not_change_earlier_after_published" do
    context "when setting deadline to earlier date" do
      let(:item) { create(:item, :with_max_five_images, :published, entry_deadline_at: Date.current + 5.days) }

      it "validates deadline to not change" do
        item.assign_attributes(entry_deadline_at: Date.current + 2.days)

        expect(item.valid?(:publish)).to be false
        expect(item.errors[:entry_deadline_at]).to include("は元の締切日以降に設定してください")
      end
    end

    context "when setting deadline to later date" do
      let(:item) { create(:item, :with_max_five_images, :published, entry_deadline_at: Date.current + 5.days) }

      it "allows deadline change" do
        item.assign_attributes(entry_deadline_at: Date.current + 7.days)

        expect(item.valid?(:publish)).to be true
        expect(item.errors.full_messages).to be_empty
      end
    end

    context "when item is draft" do
      let(:item) { create(:item, :with_max_five_images, entry_deadline_at: Date.current + 5.days) }

      it "allows deadline change to earlier date" do
        item.assign_attributes(entry_deadline_at: Date.current + 2.days)

        expect(item.valid?(:publish)).to be true
        expect(item.errors.full_messages).to be_empty
      end
    end
  end

  describe "#set_entry_deadline_at_end_of_day" do
    let(:item) { build(:item, entry_deadline_at: entry_deadline_at) }

    context "when entry_deadline_at is given from date_field" do
      let(:entry_deadline_at) { "2025-11-17" }

      it "sets entry_deadline_at to end of day" do
        item.save!
        expect(item.entry_deadline_at.to_i).to eq (Time.zone.parse("2025-11-17 23:59:59").to_i)
      end
    end
  end

  describe "#comment_watch_by_seller" do
    let(:user) { create(:user) }

    context "when publishing item" do
      it "create watch by seller" do
        item = create(:item, :with_max_five_images, :published, user: user)
        expect(item.watchers).to include(user)
      end
    end
  end

  describe "#notify_publishing" do
    context "when published item is created" do
      it "sends webhook notification" do
        item = create(:item, :with_max_five_images, :published)

        expect(webhook_double).to have_received(:notify_item_published).with(item)
      end
    end

    context "when draft item is created" do
      let(:item) { build(:item, :with_max_five_images) }

      it "does not send webhook notification" do
        item.save!

        expect(webhook_double).not_to have_received(:notify_item_published).with(item)
      end
    end

    context "when status is not changed from published" do
      let(:item) { create(:item, :with_max_five_images, :published, entry_deadline_at: Date.current) }

      it "does not send webhook notification" do
        expect(webhook_double).to have_received(:notify_item_published).with(item).once

        item.update!(entry_deadline_at: Date.tomorrow)

        expect(webhook_double).to have_received(:notify_item_published).with(item).once
      end
    end
  end

  describe "#notify_deadline_extension" do
    context "when entry_deadline_at is extended" do
      let(:item) { create(:item, :with_max_five_images, :published, entry_deadline_at: Date.current) }

      it "sends webhook notification" do
        item.update!(entry_deadline_at: Date.tomorrow)

        expect(webhook_double).to have_received(:notify_item_deadline_extended).with(item.applicants, item)
      end
    end

    context "when entry_deadline_at and status is changed" do
      let(:item) { create(:item, :with_max_five_images, entry_deadline_at: Date.current) }

      it "does not send webhook notification" do
        item.status = :published
        item.entry_deadline_at = Date.tomorrow
        item.save!

        expect(webhook_double).not_to have_received(:notify_item_deadline_extended).with(item.applicants, item)
      end
    end
  end

  describe "#notify_close" do
    context "when item is closed by user" do
      let(:item) { create(:item, :with_max_five_images, :published) }
      let(:applicant) { create(:user) }

      it "sends notification to applicants" do
        create(:entry, item: item, user: applicant)

        item.close!(by: :user)

        expect(Notification.last.user).to eq(applicant)
        expect(webhook_double).to have_received(:notify_item_closed).with(item.applicants, item)
      end
    end

    context "when item is closed by deadline" do
      let(:seller) { create(:user) }
      let(:item) { create(:item, :with_max_five_images, :published, user: seller, entry_deadline_at: Date.yesterday) }

      it "sends notification to seller" do
        item.close!(by: :lottery)

        expect(Notification.last.user).to eq(seller)
        expect(webhook_double).to have_received(:notify_lottery_skipped).with(item.user, item)
      end
    end
  end
end
