class CreateWhitelistings < ActiveRecord::Migration
  def change
    create_table :whitelistings do |t|
      t.string :whitelist
      t.string :whitelist_type
      t.integer :campaign_id

      t.timestamps
    end
  end
end
