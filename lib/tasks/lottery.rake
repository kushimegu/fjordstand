namespace :lottery do
  desc "締切が過ぎた商品の抽選を行う"
  task select_buyer: :environment do
    items = Item.expired

    items.find_each do |item|
      Lottery.new(item).run
    end
  end
end
