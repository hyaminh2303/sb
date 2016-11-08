class CreateApplicationTrackings < ActiveRecord::Migration
  def change
    create_table :application_trackings do |t|
      t.integer :campaign_id
      t.integer :banner_id
      t.integer :views
      t.integer :clicks
      t.string :app_name
      t.date :date

      t.timestamps
    end
    add_index :application_trackings, :campaign_id
    add_index :application_trackings, :banner_id
  end
end
