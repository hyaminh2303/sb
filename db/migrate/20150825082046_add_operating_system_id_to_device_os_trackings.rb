class AddOperatingSystemIdToDeviceOsTrackings < ActiveRecord::Migration
  def change
    add_column :device_os_trackings, :operating_system_id, :integer
    add_index :device_os_trackings, :operating_system_id
  end
end
