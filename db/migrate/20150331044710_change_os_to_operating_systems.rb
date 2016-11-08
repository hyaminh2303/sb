class ChangeOsToOperatingSystems < ActiveRecord::Migration
  def change
    rename_column :campaigns_os, :os_id, :operating_system_id
    rename_table :campaigns_os, :campaigns_operating_systems
  end
end
