class AddCitiesRadiusToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :cities_radius, :float, default: 10
  end
end
