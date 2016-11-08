class AddUpdatedStatusAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :updated_status_at, :datetime
  end
end
