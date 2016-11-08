class CreateLocationTrackingRecords < ActiveRecord::Migration
  def change
    create_table :location_tracking_records do |t|
      t.belongs_to :creative, index: true
      t.belongs_to :campaign_location, index: true
      t.integer :view
      t.integer :click
      t.date :date

      t.timestamps
    end
  end
end
