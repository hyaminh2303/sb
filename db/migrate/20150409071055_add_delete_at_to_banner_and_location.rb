class AddDeleteAtToBannerAndLocation < ActiveRecord::Migration
  def change
    add_column :banners, :deleted_at, :datetime
    add_index :banners, :deleted_at
    add_column :campaign_locations, :deleted_at, :datetime
    add_index :campaign_locations, :deleted_at
  end
end
