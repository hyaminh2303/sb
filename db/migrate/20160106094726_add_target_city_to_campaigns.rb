class AddTargetCityToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :target_city, :boolean, default: false
  end
end
