class CreateCosts < ActiveRecord::Migration
  def change
    create_table :costs do |t|
      t.belongs_to :country, index: true
      t.string :pricing_model, index: true
      t.money :price
      t.timestamps
    end
  end
end
