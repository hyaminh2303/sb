class RemoveCityTrackings < ActiveRecord::Migration
  def change
    drop_table :city_trackings
  end
end
