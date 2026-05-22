class AddNullFalseToCommentsAndMessagesBody < ActiveRecord::Migration[8.1]
  def change
    change_column_null :comments, :body, false
    change_column_null :messages, :body, false
  end
end
