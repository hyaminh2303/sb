class ChangeWhitelistTypeInWhitelists < ActiveRecord::Migration
  def change
    change_column :whitelistings, :whitelist_type, :integer 
  end
end
