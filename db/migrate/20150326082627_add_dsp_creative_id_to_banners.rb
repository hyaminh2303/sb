class AddDspCreativeIdToBanners < ActiveRecord::Migration
  def change
    add_column :banners, :dsp_creative_id, :integer
  end
end
