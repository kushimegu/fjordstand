require 'rails_helper'

RSpec.describe DestroyEntriesJob, type: :job do
  let(:seller) { create(:user) }
  let(:item) { create(:item, :published, user: seller) }
  let(:buyer) { create(:user) }

  before do
    ActiveJob::Base.queue_adapter = :test
    create(:entry, item: item, user: buyer)
  end

  describe '#perform_later' do
    it 'enqueues the job' do
      described_class.perform_later(item.id)
      expect(described_class).to have_been_enqueued.with(item.id)
    end

    it 'destroys the entry' do
      expect { described_class.perform_now(item.id) }.to change(Entry, :count).by(-1)
    end
  end
end
