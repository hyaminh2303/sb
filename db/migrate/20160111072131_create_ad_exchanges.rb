class CreateAdExchanges < ActiveRecord::Migration
  def change
    create_table :ad_exchanges do |t|
      t.string :name
      t.string :ad_exchange_code

      t.timestamps
    end
  end
end
