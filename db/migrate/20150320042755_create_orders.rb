class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :campaign, index: true
      t.integer :dsp_id
      t.integer :dsp_campaign_id

      t.timestamps
    end
  end
end
