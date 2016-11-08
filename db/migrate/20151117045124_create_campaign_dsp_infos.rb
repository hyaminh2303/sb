class CreateCampaignDspInfos < ActiveRecord::Migration
  def change
    create_table :campaign_dsp_infos do |t|
      t.float :ecpc
      t.float :ecpm
      t.float :ecpi
      t.float :spend
      t.float :ctr
      t.float :cvr
      t.float :cpi_revenue
      t.integer :resume
      t.integer :complete
      t.integer :third_quartile
      t.integer :mid_point
      t.integer :first_quartile
      t.integer :start
      t.integer :installs
      t.integer :campaign_id
      t.integer :clicks
      t.integer :impressions
      t.date :date
      
      t.timestamps
    end if !table_exists?(:campaign_dsp_infos)
  end
end

