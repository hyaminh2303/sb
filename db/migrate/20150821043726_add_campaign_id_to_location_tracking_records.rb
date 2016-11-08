class AddCampaignIdToLocationTrackingRecords < ActiveRecord::Migration
  def change
    add_column :location_tracking_records, :campaign_id, :integer
    add_index :location_tracking_records, :campaign_id
  end
end
