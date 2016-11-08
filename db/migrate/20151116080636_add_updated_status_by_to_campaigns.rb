class AddUpdatedStatusByToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :updated_status_by, :string
  end
end
