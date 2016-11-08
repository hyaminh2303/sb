class CreateCreativeTrackings < ActiveRecord::Migration
  def change
    create_table :creative_trackings do |t|
      t.integer :campaign_id
      t.integer :banner_id
      t.integer :views
      t.integer :clicks
      t.string :creative_name
      t.date :date

      t.timestamps
    end
    add_index :creative_trackings, :campaign_id
    add_index :creative_trackings, :banner_id
  end
end
