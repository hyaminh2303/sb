class CreateBidstalkTasks < ActiveRecord::Migration
  def change
    create_table :bidstalk_tasks do |t|
      t.references :campaign, index: true
      t.references :banner, index: true
      t.string :type
      t.boolean :done, default: false
      t.timestamps
    end
  end
end
