class CreateCityDspMappings < ActiveRecord::Migration
  def change
    create_table :city_dsp_mappings do |t|
      t.integer :country_dsp_mapping_id
      t.integer :city_id
      t.integer :dsp_id
      t.string :name
      t.integer :city_dsp_id

      t.timestamps
    end
  end
end
