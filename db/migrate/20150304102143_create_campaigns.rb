class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name, :null => false
      t.string :ad_domain, :null => false
      t.belongs_to :category
      t.belongs_to :country
      t.string :timezone
      t.integer :pricing_model, default: 0
      t.money :price
      t.datetime :start_time
      t.datetime :end_time
      t.belongs_to :user, index: true
      t.boolean :is_draft, default: true, index: true
      t.timestamps
    end
  end
  def self.down
    drop_table :campaigns
  end
end
