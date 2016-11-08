class CreateCampaignsCategories < ActiveRecord::Migration
  def change
    create_table :campaigns_categories do |t|
      t.integer :category_id
      t.integer :campaign_id

      t.timestamps
    end
    add_index :campaigns_categories, :category_id
    add_index :campaigns_categories, :campaign_id
  end
end
