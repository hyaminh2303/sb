class AddMessageToBidstalkTasks < ActiveRecord::Migration
  def change
    add_column :bidstalk_tasks, :message, :text
  end
end
