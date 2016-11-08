class CreateDailyTrackingRecords < ActiveRecord::Migration
  def change
    create_table :daily_tracking_records do |t|
      t.belongs_to :creative, index: true
      t.belongs_to :order, index: true
      t.belongs_to :campaign, index: true
      t.integer :dsp_id
      t.integer :view
      t.integer :click
      t.date :date

      t.timestamps
    end
  end
end
