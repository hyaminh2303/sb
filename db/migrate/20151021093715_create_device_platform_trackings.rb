class CreateDevicePlatformTrackings < ActiveRecord::Migration
  def change
    create_table :device_platform_trackings do |t|
      t.integer :campaign_id
      t.integer :banner_id
      t.integer :views
      t.integer :clicks
      t.string :name
      t.date :date

      t.timestamps
    end
    add_index :device_platform_trackings, :campaign_id
    add_index :device_platform_trackings, :banner_id
  end
end
