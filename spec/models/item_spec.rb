require 'rails_helper'

RSpec.describe Item, type: :model do
  before do
    ActiveJob::Base.queue_adapter = :test
    webhook = stub_discord_webhook
  end

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

  describe ".not_expired" do
    let(:expired_item) { create(:item, :published, entry_deadline_at: Date.yesterday) }
    let(:unexpired_item) { create(:item, :published, entry_deadline_at: Date.current) }

    it "returns only not expired items" do
      expect(Item.not_expired).to eq [ unexpired_item ]
    end
  end

  describe ".expired" do
    let!(:expired_item) { create(:item, :published, entry_deadline_at: Date.yesterday) }

    before { create(:item, :published, entry_deadline_at: Date.current) }

    it "returns only expired items" do
      expect(Item.expired).to contain_exactly(expired_item)
    end
  end

  describe ".commentable" do
    let!(:published_item) { create(:item, :published) }
    let!(:closed_item) { create(:item, :closed) }
    let!(:sold_item) { create(:item, :sold) }

    it "returns items except draft" do
      create(:item)

      expect(Item.commentable).to contain_exactly(published_item, closed_item, sold_item)
    end
  end

  describe ".by_target" do
    let!(:published_item) { create(:item, :published) }
    let!(:closed_item) { create(:item, :closed) }
    let!(:sold_item) { create(:item, :sold) }
    let!(:draft_item) { create(:item) }

    context "when target is published" do
      it "returns published item" do
        expect(Item.by_target("published")).to contain_exactly(published_item)
      end
    end

    context "when target is closed" do
      it "returns closed item" do
        expect(Item.by_target("closed")).to contain_exactly(closed_item)
      end
    end

    context "when target is sold" do
      it "returns sold item" do
        expect(Item.by_target("sold")).to contain_exactly(sold_item)
      end
    end

    context "when target is draft" do
      it "returns draft item" do
        expect(Item.by_target("draft")).to contain_exactly(draft_item)
      end
    end

    context "when target is invalid" do
      it "returns all items" do
        expect(Item.by_target("invalid")).to contain_exactly(published_item, closed_item, sold_item, draft_item)
      end
    end
  end

  describe "#close!" do
    let(:user) { create(:user) }
    let(:item) { create(:item, :published, user: user) }

    context "when closed by user action" do
      it "changes status and queues job" do
        expect { item.close!(reason: :user_action) }.to have_enqueued_job(NotifyItemClosedJob).with(item.id, { reason: :user_action })
        expect(item.status).to eq("closed")
      end
    end

    context "when closed by deadline" do
      it "changes status and queues job" do
        expect { item.close!(reason: :no_applicants) }.to have_enqueued_job(NotifyItemClosedJob).with(item.id, { reason: :no_applicants })
        expect(item.status).to eq("closed")
      end
    end
  end

  describe "#editable?" do
    let(:user) { create(:user) }

    context "when item is published and has past entry deadline" do
      let(:item) { create(:item, :published, user: user, entry_deadline_at: Date.yesterday) }

      it "is not editable" do
        expect(item.editable?).to be false
      end
    end

    context "when item is sold" do
      let(:item) { create(:item, :sold, user: user) }

      it "is not editable" do
        expect(item.editable?).to be false
      end
    end

    context "when item is published and before entry deadline" do
      let(:item) { create(:item, :published, user: user, entry_deadline_at: Date.tomorrow) }

      it "is editable" do
        expect(item.editable?).to be true
      end
    end

    context "when item is draft" do
      let(:item) { create(:item, user: user) }

      it "is editable" do
        expect(item.editable?).to be true
      end
    end

    context "when item is closed" do
      let(:item) { create(:item, :closed, user: user) }

      it "is editable" do
        expect(item.editable?).to be true
      end
    end
  end

  describe "#commentable?" do
    let(:user) { create(:user) }

    context "when item is draft" do
      let(:item) { create(:item, user: user) }

      it "is not commentable" do
        expect(item.commentable?).to be false
      end
    end

    context "when item is published" do
      let(:item) { create(:item, :published, user: user) }

      it "is commentable" do
        expect(item.commentable?).to be true
      end
    end
  end

  describe "#participant?" do
    let(:seller) { create(:user) }
    let(:admin) { create(:user, uid: 123) }
    let(:buyer) { create(:user) }
    let(:item) { create(:item, :sold, user: seller) }

    before { create(:entry, :won, user: buyer, item: item) }

    context "when user is seller" do
      it "returns true" do
        expect(item.participant?(seller)).to be true
      end
    end

    context "when user is buyer" do
      it "returns true" do
        expect(item.participant?(buyer)).to be true
      end
    end

    context "when user is admin and is not participant" do
      it "returns false" do
        expect(item.participant?(admin)).to be false
      end
    end
  end

  describe "#deadline_must_be_today_or_later" do
    let(:item) { build(:item, :with_item_image, entry_deadline_at: entry_deadline_at) }

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
      end
    end

    context "when setting deadline to tomorrow" do
      let(:entry_deadline_at) { Date.tomorrow }

      it "can set deadline to tomorrow" do
        expect(item.valid?(:publish)).to be true
      end
    end
  end

  describe "#price_cannot_be_changed_after_published" do
    context "when item is already published" do
      let(:item) { create(:item, :published, price: 1000) }

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
      end
    end
  end

  describe "#deadline_cannot_be_changed_earlier_after_published" do
    context "when setting deadline to earlier date" do
      let(:item) { create(:item, :with_item_image, :published, entry_deadline_at: Date.current + 5.days) }

      it "validates deadline to not change" do
        item.assign_attributes(entry_deadline_at: Date.current + 2.days)

        expect(item.valid?(:publish)).to be false
        expect(item.errors[:entry_deadline_at]).to include("は元の締切日以降に設定してください")
      end
    end

    context "when setting deadline to later date" do
      let(:item) { create(:item, :with_item_image, :published, entry_deadline_at: Date.current + 5.days) }

      it "allows deadline change" do
        item.assign_attributes(entry_deadline_at: Date.current + 7.days)

        expect(item.valid?(:publish)).to be true
      end
    end

    context "when item is draft" do
      let(:item) { create(:item, :with_item_image, entry_deadline_at: Date.current + 5.days) }

      it "allows deadline change to earlier date" do
        item.assign_attributes(entry_deadline_at: Date.current + 2.days)

        expect(item.valid?(:publish)).to be true
      end
    end
  end

  describe "#set_entry_deadline_at_end_of_day" do
    context "when entry_deadline_at is given from date_field" do
      it "sets entry_deadline_at to end of day" do
        item = build(:item, entry_deadline_at: "2025-11-17")
        item.save!
        expect(item.entry_deadline_at.to_i).to eq (Time.zone.parse("2025-11-17 23:59:59").to_i)
      end
    end
  end

  describe "#comment_watch_by_seller" do
    let(:user) { create(:user) }

    context "when publishing item" do
      it "create watch by seller" do
        item = create(:item, user: user)

        expect { item.update!(status: :published) }.to change { item.watchers.count }.by(1)
        expect(item.watchers).to include(user)
      end
    end
  end

  describe "#notify_publishing" do
    context "when published item is created" do
      it "sends webhook notification" do
        item = create(:item)

        expect { item.update!(status: :published) }.to have_enqueued_job(NotifyItemPublishedJob).with(item.id)
      end
    end

    context "when draft item is created" do
      it "does not send webhook notification" do
        item = build(:item, :with_item_image)

        expect { item.save! }.not_to have_enqueued_job(NotifyItemPublishedJob)
      end
    end

    context "when status is not changed from published" do
      it "does not send webhook notification" do
        item = create(:item, :published, entry_deadline_at: Date.current)

        expect { item.update!(entry_deadline_at: Date.tomorrow) }.not_to have_enqueued_job(NotifyItemPublishedJob)
      end
    end
  end

  describe "#notify_deadline_extension" do
    context "when entry_deadline_at is extended" do
      it "sends webhook notification" do
        item = create(:item, :published, entry_deadline_at: Date.current)

        expect { item.update!(entry_deadline_at: Date.tomorrow) }.to have_enqueued_job(NotifyDeadlineExtendedJob).with(item.id)
      end
    end

    context "when entry_deadline_at and status is changed" do
      it "does not send webhook notification" do
        item = create(:item, entry_deadline_at: Date.current)

        expect { item.update!(status: :published, entry_deadline_at: Date.tomorrow) }.not_to have_enqueued_job(NotifyDeadlineExtendedJob)
      end
    end
  end
end
