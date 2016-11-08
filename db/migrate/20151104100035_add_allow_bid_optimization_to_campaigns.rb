class AddAllowBidOptimizationToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :allow_bid_optimization, :boolean, default: true
  end
end
