class ChangeCampaignDspStatus < ActiveRecord::Migration
  def change
    rename_column :campaigns, :dsp_status, :status
  end
end
