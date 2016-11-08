class RenameCarrierNameToNameInCarrierTrackings < ActiveRecord::Migration
  def change
    rename_column :carrier_trackings, :carrier_name, :name
  end
end
