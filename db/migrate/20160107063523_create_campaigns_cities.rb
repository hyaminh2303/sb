class CreateCampaignsCities < ActiveRecord::Migration
  def change
    create_table :campaigns_cities, id: false do |t|
      t.integer :campaign_id
      t.integer :city_id
    end
  end
end
