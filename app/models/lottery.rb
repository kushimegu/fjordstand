class Lottery
  def initialize(item)
    @item = item
  end

  def run
    return if @item.winner.present?

    if @item.entries.exists?
      entries = @item.entries
      winner = entries.offset(rand(entries.count)).first
      losers = entries.where.not(id: winner.id)
      losers.update_all(status: :lost)
      winner.update!(status: :won)
      @item.update!(status: :sold)
    else
      @item.close(reason: :no_applicants)
    end
  end
end
