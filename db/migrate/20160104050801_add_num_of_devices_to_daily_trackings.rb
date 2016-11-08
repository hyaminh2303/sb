class AddNumOfDevicesToDailyTrackings < ActiveRecord::Migration
  def change
    add_column :daily_tracking_records, :devices, :text
    add_column :daily_tracking_records, :num_of_devices, :integer
  end
end
