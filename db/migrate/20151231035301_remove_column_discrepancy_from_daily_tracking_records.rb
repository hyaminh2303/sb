class RemoveColumnDiscrepancyFromDailyTrackingRecords < ActiveRecord::Migration
  def change
    remove_column :daily_tracking_records, :discrepancy_views, :float
    remove_column :daily_tracking_records, :discrepancy_clicks, :float
  end
end
