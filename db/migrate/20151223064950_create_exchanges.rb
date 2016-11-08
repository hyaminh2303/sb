class CreateExchanges < ActiveRecord::Migration
  def change
    create_table :exchanges do |t|
      t.string :name
      t.date :date
      t.integer :campaign_id
      t.integer :banner_id
      t.integer :views
      t.integer :clicks

      t.timestamps
    end
  end
end
