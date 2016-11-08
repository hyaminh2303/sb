class AddStatusToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :dsp_status, :integer
  end
end
