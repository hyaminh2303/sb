class RenameAppNameToNameInApplicationTrackings < ActiveRecord::Migration
  def change
    rename_column :application_trackings, :app_name, :name
  end
end
