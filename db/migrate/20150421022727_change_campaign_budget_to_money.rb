class ChangeCampaignBudgetToMoney < ActiveRecord::Migration
  def change
    remove_column :campaigns, :budget_cents

    add_money :campaigns, :budget
  end
end
