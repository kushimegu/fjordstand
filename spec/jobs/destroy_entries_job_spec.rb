require 'rails_helper'

RSpec.describe DestroyEntriesJob, type: :job do
  let(:seller) { create(:user) }
  let(:item) { create(:item, :published, user: seller) }
  let(:applicant) { create(:user) }
  let(:other_applicant) { create(:user) }

  before do
    ActiveJob::Base.queue_adapter = :test

    create(:entry, item: item, user: applicant)
    create(:entry, item: item, user: other_applicant)
  end

  describe '#perform_later' do
    it 'enqueues the job' do
      DestroyEntriesJob.perform_later(item.id)
      expect(DestroyEntriesJob).to have_been_enqueued.with(item.id)
    end

    it 'enqueues DestroyEntriesJob' do
      expect { DestroyEntriesJob.perform_now(item.id) }.to change(Entry, :count).by(-2)
    end
  end
end
