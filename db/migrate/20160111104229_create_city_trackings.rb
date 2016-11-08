class CreateCityTrackings < ActiveRecord::Migration
  def change
    create_table :city_trackings do |t|
      t.references :campaign, index: true
      t.references :banner, index: true
      t.references :city, index: true
      t.date :date
      t.integer :views, default: 0
      t.integer :clicks, default: 0

      t.timestamps
    end
  end
end
