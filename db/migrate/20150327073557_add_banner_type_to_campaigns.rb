class AddBannerTypeToCampaigns < ActiveRecord::Migration
  def change
    add_reference :campaigns, :banner_type, index: true
  end
end
