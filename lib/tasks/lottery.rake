namespace :lottery do
  desc "run lottery to select winner for items whose deadline has passed"
  task select_winner: :environment do
    items = Item.expired

    items.find_each do |item|
      Lottery.new(item).run
    end
  end
end
