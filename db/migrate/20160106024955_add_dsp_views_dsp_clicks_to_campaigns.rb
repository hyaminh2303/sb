class AddDspViewsDspClicksToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :dsp_views, :integer, default: 0
    add_column :campaigns, :dsp_clicks, :integer, default: 0
  end
end
