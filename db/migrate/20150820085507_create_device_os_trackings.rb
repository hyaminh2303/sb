class CreateDeviceOsTrackings < ActiveRecord::Migration
  def change
    create_table :device_os_trackings do |t|
      t.integer :campaign_id
      t.integer :banner_id
      t.integer :views
      t.integer :clicks
      t.string :device_os_name
      t.date :date

      t.timestamps
    end
    add_index :device_os_trackings, :campaign_id
    add_index :device_os_trackings, :banner_id
  end
end
