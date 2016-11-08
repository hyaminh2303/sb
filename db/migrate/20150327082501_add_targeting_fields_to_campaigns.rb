class AddTargetingFieldsToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :os_ids, :string
    add_column :campaigns, :age_range_ids, :string
    add_column :campaigns, :gender_ids, :string
    add_column :campaigns, :interest_ids, :string
  end
end
