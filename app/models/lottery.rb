class Lottery
  def initialize(item)
    @item = item
  end

  def run
    if @item.entries.exists?
      entries = @item.entries
      winner = entries.offset(rand(entries.count)).first
      losers = entries.where.not(id: winner.id)
      losers.update_all(status: :lost)
      winner.update!(status: :won)
      @item.update!(status: :sold)
      entries.each do |entry|
        Notification.create!(user: entry.user, notifiable: entry)
      end
      Notification.create!(user: @item.user, notifiable: @item)
      DiscordWebhook.new.notify_lottery_completed(@item.applicants + [ @item.user ], @item)
    else
      @item.close!(by: :lottery)
    end
  end
end
