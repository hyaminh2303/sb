class RenameDiscrepancyColumnFromCampaignDspInfos < ActiveRecord::Migration
  def change
    rename_column :campaign_dsp_infos, :discrepancy_views, :daily_tracking_views
    rename_column :campaign_dsp_infos, :discrepancy_clicks, :daily_tracking_clicks
  end
end
