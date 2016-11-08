class RemoveDeviceOsNameFromDeviceOsTrackings < ActiveRecord::Migration
  def change
    remove_column :device_os_trackings, :device_os_name, :string
  end
end
