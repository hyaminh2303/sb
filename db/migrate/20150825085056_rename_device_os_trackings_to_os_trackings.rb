class RenameDeviceOsTrackingsToOsTrackings < ActiveRecord::Migration
  def change
    rename_table :device_os_trackings, :os_trackings
  end
end
