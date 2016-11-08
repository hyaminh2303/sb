class ChangeBudgetFormatInUsers < ActiveRecord::Migration
  def change
    change_column :users, :budget, :decimal, precision: 30, scale: 10
  end
end
