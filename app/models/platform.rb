class Platform < ActiveRecord::Base
  # region Use shared table
  self.table_name_prefix = ''
  # endregion

  scope :bidstalk, -> { find_by_name(:bidstalk) }
  scope :pocket_math, -> { find_by_name(:pocketmath) }

end