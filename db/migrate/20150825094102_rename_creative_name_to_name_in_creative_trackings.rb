class RenameCreativeNameToNameInCreativeTrackings < ActiveRecord::Migration
  def change
    rename_column :creative_trackings, :creative_name, :name
  end
end
