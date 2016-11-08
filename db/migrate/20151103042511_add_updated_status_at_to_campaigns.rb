class AddUpdatedStatusAtToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :updated_status_at, :datetime
  end
end
