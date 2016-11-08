class AddViewDiscrepancyClickDiscrepancyToDailyTrackingRecords < ActiveRecord::Migration
  def change
    add_column :daily_tracking_records, :discrepancy_views, :float, default: 0
    add_column :daily_tracking_records, :discrepancy_clicks, :float, default: 0
  end
end
