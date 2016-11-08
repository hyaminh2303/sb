class ChangeCampaignTimezoneToNumber < ActiveRecord::Migration
  def up
    change_column :campaigns, :timezone, :integer, default: 0, null: false
    rename_column :campaigns, :timezone, :timezone_id
  end

  def down
    change_column :campaigns, :timezone, :string
    rename_column :campaigns, :timezone_id, :timezone
  end
end
