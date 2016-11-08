class CreateCarrierTrackings < ActiveRecord::Migration
  def change
    create_table :carrier_trackings do |t|
      t.integer :campaign_id
      t.integer :banner_id
      t.integer :views
      t.integer :clicks
      t.string :carrier_name
      t.date :date

      t.timestamps
    end
    add_index :carrier_trackings, :campaign_id
    add_index :carrier_trackings, :banner_id
  end
end
