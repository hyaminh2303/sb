class AddDiscrepancyViewsDiscrepancyClicksToCampaignDspInfos < ActiveRecord::Migration
  def change
    add_column :campaign_dsp_infos, :discrepancy_views, :float, default: 0
    add_column :campaign_dsp_infos, :discrepancy_clicks, :float, default: 0
  end
end
