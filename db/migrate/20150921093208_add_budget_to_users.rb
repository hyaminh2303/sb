class AddBudgetToUsers < ActiveRecord::Migration
  def change
    add_column :users, :budget, :float, default: 0
  end
end
