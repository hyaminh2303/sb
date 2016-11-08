class ChangeFieldNameOfTrackingTables < ActiveRecord::Migration
  def change

    rename_column :location_tracking_records, :creative_id, :banner_id
    rename_column :location_tracking_records, :view, :views
    rename_column :location_tracking_records, :click, :clicks

    rename_column :daily_tracking_records, :creative_id, :banner_id
    rename_column :daily_tracking_records, :view, :views
    rename_column :daily_tracking_records, :click, :clicks
  end
end
