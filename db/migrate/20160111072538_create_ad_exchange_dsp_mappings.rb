class CreateAdExchangeDspMappings < ActiveRecord::Migration
  def change
    create_table :ad_exchange_dsp_mappings do |t|
      t.integer :ad_exchange_id
      t.integer :dsp_id
      t.integer :ad_exchange_dsp_id
      t.timestamps
    end
  end
end

