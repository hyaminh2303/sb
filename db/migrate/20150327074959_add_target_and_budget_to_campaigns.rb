class AddTargetAndBudgetToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :budget_cents, :integer, null: false, default: 0, after: :price_currency
    add_column :campaigns, :target, :integer, null: false, default: 0, after: :price_currency
  end
end
