class UpdateTargetingFields < ActiveRecord::Migration
  def change
    remove_column :campaigns, :os_ids
    remove_column :campaigns, :age_range_ids
    remove_column :campaigns, :gender_ids
    remove_column :campaigns, :interest_ids

    create_table :campaigns_genders, id: false do |t|
      t.belongs_to :campaign, index: true
      t.belongs_to :gender, index: true
    end
    create_table :campaigns_interests, id: false do |t|
      t.belongs_to :campaign, index: true
      t.belongs_to :interest, index: true
    end
    create_table :campaigns_age_ranges, id: false do |t|
      t.belongs_to :campaign, index: true
      t.belongs_to :age_range, index: true
    end
    create_table :campaigns_os, id: false do |t|
      t.belongs_to :campaign, index: true
      t.belongs_to :os, index: true
    end
  end

end
