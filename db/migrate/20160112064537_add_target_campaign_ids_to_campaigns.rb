class AddTargetCampaignIdsToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :target_campaign_ids, :text
  end
end
