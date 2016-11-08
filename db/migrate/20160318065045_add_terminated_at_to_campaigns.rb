class AddTerminatedAtToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :terminated_at, :datetime
  end
end
