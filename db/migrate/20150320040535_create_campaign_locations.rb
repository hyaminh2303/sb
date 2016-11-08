class CreateCampaignLocations < ActiveRecord::Migration
  def change
    create_table :campaign_locations do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.belongs_to :campaign, index: true
      t.float :radius
      t.string :key

      t.timestamps
    end
  end
end
