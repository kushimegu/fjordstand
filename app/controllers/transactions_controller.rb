class TransactionsController < ApplicationController
  def index
    @items = Item.where(user_id: current_user.id, status: :sold)
                  .or(Item.where(id: Entry.where(user_id: current_user.id, status: :won).select(:item_id)))
  end
end
