class Lottery
  def initialize(item)
    @item = item
  end

  def run
    if @item.entries.exists?
      winner = @item.entries.offset(rand(@item.entries.count)).first
      @item.entries.where.not(id: winner.id).update_all(status: :lost)
      winner.update!(status: :won)
      @item.update!(status: :sold)
    else
      @item.update!(status: :closed)
    end
  end
end
