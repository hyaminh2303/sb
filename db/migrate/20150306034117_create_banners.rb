class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.belongs_to :campaign, index: true
      t.string :name
      t.text :landing_url
      t.text :image
      t.string :original_filename
      t.string :key
      t.timestamps
    end
  end
end
