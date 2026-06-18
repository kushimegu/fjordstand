class Lottery
  def initialize(item)
    @item = item
  end

  def run
    return if @item.winner.present?

    entries = @item.entries.to_a
    if entries.any?
      won_entry = entries.sample
      lost_entries = entries - [ won_entry ]
      ActiveRecord::Base.transaction do
        @item.entries.where(id: lost_entries.map(&:id)).update_all(status: :lost) if lost_entries.any?
        won_entry.update!(status: :won)
        @item.update!(status: :sold)
      end
    else
      @item.close!(reason: :no_applicants)
    end
  end
end
